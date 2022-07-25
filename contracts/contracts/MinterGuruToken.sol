// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MinterGuruToken is AccessControl, ERC20 {
    /// @dev VestingRecord - struct with vesting
    struct VestingRecord {
        address receiver;                    // receiver of vesting tokens
        uint256 stepValue;                   // value unlocked at every period
        uint256 stepDuration;                // single period duration in seconds
        uint256 steps;                       // count of unlock periods
        uint256 createdAt;                   // started at timestamp
        uint256 withdrawn;                   // already released
        uint256 revokedAt;                   // revocation timestamp
    }

    /// @dev CommunityEvent - struct with some gaming activity details
    /// Reward calculates as follows:
    /// expectedSupply = ((now - start) / duration) * value
    /// eventRate = currentSupply / expectedSupply
    /// By thresholds list we are building interval set: let's assume that length of thresholds equals to n.
    /// Then our set will going to be: [0, thresholds[0]], [thresholds[1], thresholds[2]], [thresholds[n-2], thresholds[n-1]]
    /// For each interval we have token value in values list, so length of values must equal to length(thresholds)+1
    ///
    /// There is one exception from above algorythm. If less then 20% of event passed, then reward will equal to reward for interval, which includes 100%
    struct CommunityEvent {
        uint256 id;                             // event id
        uint256 value;                          // total value to distribute
        uint256 start;                          // start of event - unix timestamp in seconds
        uint256 finish;                         // end of event - unix timestamp in seconds
        uint256[] thresholds;                   // right bounds of intervals in percents (100 means 0.01%)
        uint256[] values;                       // values for intervals. length must equal to length(thresholds)+1
        uint256 currentSupply;                  // tokens minted via this event
    }

    /// @dev VestingStarted - event emitted when vesting started for some receiver
    event VestingStarted(address indexed receiver, uint256 stepValue, uint256 stepDuration, uint256 steps);

    /// @dev VestingWithdrawn - event emitted when some amount of vesting tokens
    event VestingWithdrawn(address indexed receiver, uint256 value);

    /// @dev VestingFullWithdrawn - event emitted when receiver withdrew all tokens
    event VestingFullWithdrawn(address indexed receiver, uint256 totalValue);

    /// @dev VestingRevoked - event emitted when vesting of receiver is revoked
    event VestingRevoked(address indexed receiver, uint256 totalValue);

    /// @dev CommunityEventCreated - event emitted when game event is created
    event CommunityEventCreated(uint256 indexed id, uint256 value, uint256 start, uint256 finish,
        uint256[] thresholds, uint256[] values);

    /// @dev CommunityEventFinished - event emitted when all tokens from event will be distributed
    event CommunityEventFinished(uint256 indexed id);

    // constants
    bytes32 public constant LIQUIDITY_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000001;
    bytes32 public constant VESTING_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000002;
    bytes32 public constant COMMUNITY_REWARD_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000003;
    uint256 public constant PERCENT_MULTIPLIER = 10000;  // 100 means 1%. Example: 2/10 - 2*10000/10 = 2000 which is 20%

    uint256 public totalLimit;                         // limit of minting tokens amount
    uint256 public vestingLeftSupply;                  // tokens locked for vesting (minted + locked)
    uint256 public communityRewardLeftSupply;          // tokens minted for rewards in game activities
    uint256 public burned;                             // amount of burned tokens

    uint256 eventsCount = 0;                                          // total count of events
    mapping(uint256 => CommunityEvent) public currentEvents;          // current game event
    mapping(address => VestingRecord) public vestingRecords;          // vestings

    /// @dev constructor
    /// @param _totalLimit - limit of amount of minted tokens
    /// @param _liquidityAmount - amount for liquidity
    /// @param _vestingAmount - amount for vesting program
    /// @param _communityRewardAmount - amount for rewards in community events
    /// @param _liquidityAdmin - account, which will receive liquidity tokens
    /// @param _vestingAdmin - account, which will have permission to create/revoke vesting
    /// @param _gameRewardAdmin - account, which will have permission to create gaming events and mint rewards
    constructor(
        uint256 _totalLimit,
        uint256 _liquidityAmount,
        uint256 _vestingAmount,
        uint256 _communityRewardAmount,
        address _liquidityAdmin,
        address _vestingAdmin,
        address _gameRewardAdmin
    ) ERC20("MinterGuru", "MIGU") {
        require(_totalLimit == _liquidityAmount + _vestingAmount + _communityRewardAmount, "MinterGuruToken: wrong limits");
        totalLimit = _totalLimit;
        vestingLeftSupply = _vestingAmount;
        communityRewardLeftSupply = _communityRewardAmount;
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(LIQUIDITY_ADMIN_ROLE, _liquidityAdmin);
        _grantRole(VESTING_ADMIN_ROLE, _vestingAdmin);
        _grantRole(COMMUNITY_REWARD_ADMIN_ROLE, _gameRewardAdmin);
        _mint(_liquidityAdmin, _liquidityAmount);
    }

    /// @dev burn tokens
    /// @param from - spending account
    /// @param value - spending value
    function burnWithOptionalReturn(address from, uint256 value) external {
        uint256 rate = PERCENT_MULTIPLIER * burned / totalLimit;
        uint256 toReturn = (rate * value) / PERCENT_MULTIPLIER;
        if (toReturn > value / 2) {
            toReturn = value / 2;
        }
        if (toReturn > 0) {
            transferFrom(from, address(this), toReturn);
            communityRewardLeftSupply += toReturn;
        }
        burned += value - toReturn;
        _spendAllowance(from, _msgSender(), value - toReturn);
        _burn(from, value - toReturn);
    }

    /// @dev create vesting record
    /// @param receiver - receiver of tokens
    /// @param stepValue - value released in each step
    /// @param stepDuration - duration of step in seconds
    /// @param steps - steps qty
    /// Emits a VestingStarted event
    function createVesting(
        address receiver,
        uint256 stepValue,
        uint256 stepDuration,
        uint256 steps
    ) external onlyRole(VESTING_ADMIN_ROLE) {
        require(stepValue > 0, "MinterGuruToken: step value must be positive");
        require(stepDuration > 0, "MinterGuruToken: step duration must be positive");
        require(steps > 0, "MinterGuruToken: steps quantity must be positive");
        require(vestingRecords[receiver].stepValue == 0, "MinterGuruToken: single receive can't have multiple vesting records");
        require(stepValue * steps <= vestingLeftSupply, "MinterGuruToken: vesting limit reached");
        vestingRecords[receiver] = VestingRecord(receiver, stepValue, stepDuration, steps, block.timestamp, 0, 0);
        vestingLeftSupply -= stepValue * steps;
        emit VestingStarted(receiver, stepValue, stepDuration, steps);
    }

    /// @dev withdraw released vesting
    /// @param value - value to withdraw. Must be less then released and not withdrawn amount of tokens
    /// Emits a VestingWithdrawn event and VestingFullWithdrawn if all tokens were released and withdrawn
    function withdrawVesting(uint256 value) external {
        VestingRecord storage record = vestingRecords[_msgSender()];
        require(record.stepValue > 0, "MinterGuruToken: vesting record doesn't exist");
        require(value <= vestingAvailableToRelease(), "MinterGuruToken: value is greater than available amount of tokens");
        _sendTokens(_msgSender(), value);
        record.withdrawn += value;
        if (record.withdrawn == record.stepValue * record.steps) {
            emit VestingFullWithdrawn(_msgSender(), record.withdrawn);
            delete vestingRecords[_msgSender()];
        }
        emit VestingWithdrawn(_msgSender(), value);
    }

    /// @dev revoke vesting. All released funds remains with receiver, but new will not unlock
    /// @param receiver - account for which vesting must be revoked
    /// Emits a VestingRevoked event and VestingWithdrawn event if there are some released and not withdrawn tokens
    function revokeVesting(address receiver) external onlyRole(VESTING_ADMIN_ROLE) {
        VestingRecord storage record = vestingRecords[receiver];
        require(record.stepValue > 0, "MinterGuruToken: vesting record doesn't exist");
        record.revokedAt = block.timestamp;
        uint256 availableAfterRevocation = record.stepValue * ((record.revokedAt - record.createdAt) / record.stepDuration);
        vestingLeftSupply += (record.stepValue * record.steps - availableAfterRevocation);
        if (availableAfterRevocation > record.withdrawn) {
            _sendTokens(receiver, availableAfterRevocation - record.withdrawn);
            emit VestingWithdrawn(receiver, availableAfterRevocation - record.withdrawn);
        }
        emit VestingRevoked(receiver, record.withdrawn);
        delete vestingRecords[receiver];
    }

    /// @dev get released amount of tokens
    /// @return released amount of tokens ready for withdraw
    function vestingAvailableToRelease() public view returns (uint256) {
        VestingRecord storage record = vestingRecords[_msgSender()];
        require(record.stepValue > 0, "MinterGuruToken: vesting record doesn't exist");
        uint256 rightBound = block.timestamp;
        if (record.revokedAt > 0) {
            rightBound = record.revokedAt;
        }
        return record.stepValue * ((rightBound - record.createdAt) / record.stepDuration) - record.withdrawn;
    }

    /// @dev Create community event
    /// @param value - total value for event
    /// @param start - start of the event
    /// @param finish - finish of the event
    /// @param thresholds - thresholds for CommunityEvent. See GameEvent docs
    /// @param values - values for CommunityEvent. See CommunityEvent docs
    /// Emits a GameEventCreated event
    function createEvent(
        uint256 value,
        uint256 start,
        uint256 finish,
        uint256[] memory thresholds,
        uint256[] memory values
    ) external onlyRole(COMMUNITY_REWARD_ADMIN_ROLE) {
        require(start >= block.timestamp, "MinterGuruToken: event start must not be in the past");
        require(start < finish, "MinterGuruToken: start must be less than finish");
        require(value <= communityRewardLeftSupply, "MinterGuruToken: limit reached");
        require(thresholds.length + 1 == values.length, "MinterGuruToken: thresholds and values sizes unmatch");
        uint256 id = eventsCount;
        eventsCount++;
        currentEvents[id] = CommunityEvent(id, value, start, finish, thresholds, values, 0);
        emit CommunityEventCreated(id, value, start, finish, thresholds, values);
    }

    /// @dev Check if there is enough supply for batch of the receivers
    /// @param id - id of CommunityEvent
    /// @param receiversCount - quantity of the receivers of the tokens
    function canMint(
        uint256 id,
        uint256 receiversCount
    ) external view returns (uint256) {
        CommunityEvent memory ev = currentEvents[id];
        if (ev.value == 0) {
            return 0;
        }
        for (uint256 i = 0; i < receiversCount; i++) {
            uint256 value = _calcGamingReward(ev);
            ev.currentSupply += value;
            if (ev.currentSupply == ev.value) {
                return i + 1;
            }
        }
        return receiversCount;
    }

    /// @dev Mint CommunityEvent reward tokens
    /// @param id - id of CommunityEvent
    /// @param to - receiver of tokens
    /// Emits a CommunityEventFinished event if supply fully minted
    function mintCommunityReward(
        uint256 id,
        address to
    ) external onlyRole(COMMUNITY_REWARD_ADMIN_ROLE) {
        address[] memory receivers = new address[](1);
        receivers[0] = to;
        _mintCommunityReward(id, receivers);
    }

    /// @dev Mint CommunityEvent reward tokens for batch of addresses
    /// @param id - id of CommunityEvent
    /// @param receivers - receivers of tokens
    /// Emits a CommunityEventFinished event if supply fully minted
    function mintCommunityRewardForMultiple(
        uint256 id,
        address[] calldata receivers
    ) external onlyRole(COMMUNITY_REWARD_ADMIN_ROLE) {
        _mintCommunityReward(id, receivers);
    }

    /// @dev Finish event. Only for expired events in which not full supply was distributed
    /// @param id - id of CommunityEvent
    /// Emits a CommunityEventFinished event
    function finishEvent(
        uint256 id
    ) external onlyRole(COMMUNITY_REWARD_ADMIN_ROLE) {
        CommunityEvent storage ev = currentEvents[id];
        require(ev.value > 0, "MinterGuruToken: event doesn't exist");
        _finishEvent(ev);
    }

    /// @dev Top up community reward pool
    /// @param value - value to transfer
    function topUpCommunityRewardPool(uint256 value) external {
        require(balanceOf(_msgSender()) >= value, "MinterGuruToken: insufficient funds");
        transferFrom(_msgSender(), address(this), value);
        communityRewardLeftSupply += value;
    }

    /// @dev Top up vesting pool
    /// @param value - value to transfer
    function topUpVestingPool(uint256 value) external {
        require(balanceOf(_msgSender()) >= value, "MinterGuruToken: insufficient funds");
        transferFrom(_msgSender(), address(this), value);
        vestingLeftSupply += value;
    }

    /// @dev Calculate pending reward for GameEvent
    /// @param id - id of CommunityEvent
    /// @return expected reward
    function calcCommunityReward(uint256 id) public view returns (uint256) {
        CommunityEvent storage ev = currentEvents[id];
        require(ev.value > 0, "MinterGuruToken: event doesn't exist");
        require(ev.start <= block.timestamp && block.timestamp <= ev.finish, "MinterGuruToken: event is not active");
        return _calcGamingReward(ev);
    }

    /// @dev Finish event internal func
    /// @param ev - CommunityEvent to finish
    /// Emits a CommunityEventFinished event
    function _finishEvent(
        CommunityEvent storage ev
    ) internal {
        if (ev.value - ev.currentSupply > 0) {
            communityRewardLeftSupply += (ev.value - ev.currentSupply);
        }
        delete currentEvents[ev.id];
        emit CommunityEventFinished(ev.id);
    }

    /// @dev mint community reward helper function
    /// @param id - id of community event
    /// @param receivers - list of receivers
    function _mintCommunityReward(uint256 id, address[] memory receivers) internal {
        CommunityEvent storage ev = currentEvents[id];
        require(ev.value > 0, "MinterGuruToken: event doesn't exist");
        require(ev.start <= block.timestamp && block.timestamp <= ev.finish, "MinterGuruToken: event is not active");
        for (uint256 i = 0; i < receivers.length; i++) {
            address to = receivers[i];
            uint256 value = _calcGamingReward(ev);
            _sendTokens(to, value);
            communityRewardLeftSupply -= value;
            ev.currentSupply += value;
            if (ev.currentSupply == ev.value) {
                require(i == receivers.length - 1, "MinterGuruToken: supply finished");
                _finishEvent(ev);
            }
        }
    }

    /// @dev Calculate pending reward for GameEvent helper function
    /// @param ev - GameEvent to check
    /// @return expected reward
    function _calcGamingReward(CommunityEvent memory ev) internal view returns (uint256) {
        if ((10 * (block.timestamp - ev.start)) / (ev.finish - ev.start) < 2) {
            return _findGamingReward(ev, PERCENT_MULTIPLIER);
        }
        uint256 expectedSupply = (ev.value * (block.timestamp - ev.start)) / (ev.finish - ev.start);
        uint256 eventRate = ev.currentSupply * PERCENT_MULTIPLIER / expectedSupply;
        uint256 res = _findGamingReward(ev, eventRate);
        if (ev.value - ev.currentSupply < res) {
            res = ev.value - ev.currentSupply;
        }
        return res;
    }

    /// @dev Helper function. If there are some returned tokens (from burn), then they will be used to send to receiver
    /// @param to - tokens receiver
    /// @param value - value to transfer
    function _sendTokens(address to, uint256 value) internal {
        uint256 returnedTokens = balanceOf(address(this));
        uint256 toTransfer;
        if (returnedTokens >= value) {
            toTransfer = value;
        } else {
            toTransfer = returnedTokens;
        }
        uint256 toMint = value - toTransfer;
        if (toTransfer > 0) {
            _transfer(address(this), to, toTransfer);
        }
        if (toMint > 0) {
            _mint(to, toMint);
        }
    }

    /// @dev Helper function to find gaming reward based on percent of minted supply (100% - expected supply)
    /// @param ev - event to check
    /// @param percent - percent to check
    /// @return expected reward
    function _findGamingReward(
        CommunityEvent memory ev,
        uint256 percent
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < ev.thresholds.length; i++) {
            if (percent < ev.thresholds[i]) {
                return ev.values[i];
            }
        }
        return ev.values[ev.values.length - 1];
    }
}
