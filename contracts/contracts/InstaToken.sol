// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InstaToken is AccessControl, ERC20 {
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

    /// @dev GameEvent - struct with some gaming activity details
    /// Reward calculates as follows:
    /// expectedSupply = ((now - start) / duration) * value
    /// eventRate = currentSupply / expectedSupply
    /// By thresholds list we are building interval set: let's assume that length of thresholds equals to n.
    /// Then our set will going to be: [0, thresholds[0]], [thresholds[1], thresholds[2]], [thresholds[n-2], thresholds[n-1]]
    /// For each interval we have token value in values list, so length of values must equal to length(thresholds)+1
    ///
    /// There is one exception from above algorythm. If less then 20% of event passed, then reward will equal to reward for interval, which includes 100%
    struct GameEvent {
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

    /// @dev GameEventCreated - event emitted when game event is created
    event GameEventCreated(uint256 indexed id, uint256 value, uint256 start, uint256 finish,
        uint256[] thresholds, uint256[] values);

    /// @dev GameEventFinished - event emitted when all tokens from event will be distributed
    event GameEventFinished(uint256 indexed id);

    // constants
    bytes32 public constant LIQUIDITY_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000001;
    bytes32 public constant VESTING_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000002;
    bytes32 public constant GAME_REWARD_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000003;
    uint256 public constant PERCENT_MULTIPLIER = 10000;  // 100 means 1%. Example: 2/10 - 2*10000/10 = 2000 which is 20%

    // token limits
    // liquidityTotalAmount + vestingTotalAmount + gameRewardTotalAmount = totalLimit
    uint256 public totalLimit;                     // limit of minting tokens amount
    uint256 public liquidityTotalAmount;           // amount of tokens for liquidity
    uint256 public vestingTotalAmount;             // amount of tokens for vesting
    uint256 public gameRewardTotalAmount;          // amount of tokens for rewards in game activities

    // spent tokens
    // liquidityTotalAmount + vestingSpent + gameRewardSpent - burned = totalSupply()
    uint256 public vestingSpent;             // tokens minted for vesting
    uint256 public vestingPendingSpent;      // tokens locked for vesting (minted + locked)
    uint256 public gameRewardSpent;          // tokens minted for rewards in game activities
    uint256 public burned;                   // amount of burned tokens

    uint256 eventsCount = 0;                                          // total count of events
    mapping(uint256 => GameEvent) public currentEvents;               // current game event
    mapping(address => VestingRecord) public vestingRecords;          // vestings

    /// @dev constructor
    /// @param _totalLimit - limit of amount of minted tokens
    /// @param _liquidityAmount - amount for liquidity
    /// @param _vestingAmount - amount for vesting program
    /// @param _gameRewardAmount - amount for rewards in gaming events
    /// @param _liquidityAdmin - account, which will receive liquidity tokens
    /// @param _vestingAdmin - account, which will have permission to create/revoke vesting
    /// @param _gameRewardAdmin - account, which will have permission to create gaming events and mint rewards
    constructor(
        uint256 _totalLimit,
        uint256 _liquidityAmount,
        uint256 _vestingAmount,
        uint256 _gameRewardAmount,
        address _liquidityAdmin,
        address _vestingAdmin,
        address _gameRewardAdmin
    ) ERC20("", "") {
        require(_totalLimit == _liquidityAmount + _vestingAmount + _gameRewardAmount, ": wrong limits");
        totalLimit = _totalLimit;
        liquidityTotalAmount = _liquidityAmount;
        vestingTotalAmount = _vestingAmount;
        gameRewardTotalAmount = _gameRewardAmount;
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(LIQUIDITY_ADMIN_ROLE, _liquidityAdmin);
        _grantRole(VESTING_ADMIN_ROLE, _vestingAdmin);
        _grantRole(GAME_REWARD_ADMIN_ROLE, _gameRewardAdmin);
        _mint(_liquidityAdmin, _liquidityAmount);
    }

    /// @dev burn tokens
    /// @param from - spending account
    /// @param value - spending value
    function burnWithOptionalReturn(address from, uint256 value) external {
        uint256 rate = PERCENT_MULTIPLIER * burned / totalSupply();
        uint256 toReturn = (rate * value) / PERCENT_MULTIPLIER;
        if (toReturn > value / 2) {
            toReturn = value / 2;
        }
        if (toReturn > 0) {
            if (toReturn > gameRewardSpent) {
                toReturn = gameRewardSpent;
            }
            transferFrom(from, address(this), toReturn);
            gameRewardSpent -= toReturn;
        }
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
        require(stepValue > 0, "");
        require(stepDuration > 0, "");
        require(steps > 0, "");
        require(vestingRecords[receiver].stepValue == 0, "");
        require(vestingPendingSpent + stepValue * steps <= vestingTotalAmount, "");
        vestingRecords[receiver] = VestingRecord(receiver, stepValue, stepDuration, steps, block.timestamp, 0, 0);
        vestingPendingSpent += stepValue * steps;
        emit VestingStarted(receiver, stepValue, stepDuration, steps);
    }

    /// @dev withdraw released vesting
    /// @param value - value to withdraw. Must be less then released and not withdrawn amount of tokens
    /// Emits a VestingWithdrawn event and VestingFullWithdrawn if all tokens were released and withdrawn
    function withdrawVesting(uint256 value) external {
        VestingRecord storage record = vestingRecords[_msgSender()];
        require(record.stepValue > 0, "");
        require(value <= vestingAvailableToRelease(), "");
        _sendTokens(_msgSender(), value);
        record.withdrawn += value;
        if (record.withdrawn == record.stepValue * record.steps) {
            emit VestingFullWithdrawn(_msgSender(), record.withdrawn);
            delete vestingRecords[_msgSender()];
        }
        vestingSpent += value;
        emit VestingWithdrawn(_msgSender(), value);
    }

    /// @dev revoke vesting. All released funds remains with receiver, but new will not unlock
    /// @param receiver - account for which vesting must be revoked
    /// Emits a VestingRevoked event and VestingWithdrawn event if there are some released and not withdrawn tokens
    function revokeVesting(address receiver) external onlyRole(VESTING_ADMIN_ROLE) {
        VestingRecord storage record = vestingRecords[receiver];
        require(record.stepValue > 0, "");
        record.revokedAt = block.timestamp;
        uint256 availableAfterRevocation = record.stepValue * ((record.revokedAt - record.createdAt) / record.stepDuration);
        vestingPendingSpent -= (record.stepValue * record.steps - availableAfterRevocation);
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
        require(record.stepValue > 0, "");
        uint256 rightBound = block.timestamp;
        if (record.revokedAt > 0) {
            rightBound = record.revokedAt;
        }
        return record.stepValue * ((rightBound - record.createdAt) / record.stepDuration) - record.withdrawn;
    }

    /// @dev
    /// @param value - total value for event
    /// @param start - start of the event
    /// @param finish - finish of the event
    /// @param thresholds - thresholds for GameEvent. See GameEvent docs
    /// @param values - values for GameEvent. See GameEvent docs
    /// Emits a GameEventCreated event
    function createEvent(
        uint256 value,
        uint256 start,
        uint256 finish,
        uint256[] memory thresholds,
        uint256[] memory values
    ) external onlyRole(GAME_REWARD_ADMIN_ROLE) {
        require(start < finish, "");
        require(value < gameRewardTotalAmount - gameRewardSpent, "");
        require(thresholds.length + 1 == values.length, "");
        uint256 id = eventsCount;
        eventsCount++;
        currentEvents[id] = GameEvent(value, start, finish, thresholds, values, 0);
        emit GameEventCreated(id, value, start, finish, thresholds, values);
    }

    /// @dev Mint GameEvent reward tokens
    /// @param id - id of GameEvent
    /// @param to - receiver of tokens
    /// Emits a GameEventFinished event if supply fully minted
    function mintGamingAward(
        uint256 id,
        address to
    ) external onlyRole(GAME_REWARD_ADMIN_ROLE) {
        GameEvent storage ev = currentEvents[id];
        require(ev.value > 0, "");
        require(ev.start <= block.timestamp && block.timestamp <= ev.finish, "");
        uint256 value = _calcGamingReward(ev);
        _sendTokens(to, value);
        gameRewardSpent += value;
        ev.currentSupply += value;
        if (ev.currentSupply == ev.value) {
            delete currentEvents[id];
            emit GameEventFinished(id);
        }
    }

    /// @dev Finish event. Only for expired events in which not full supply was distributed
    /// @param id - id of GameEvent
    /// Emits a GameEventFinished event
    function finishEvent(
        uint256 id
    ) external onlyRole(GAME_REWARD_ADMIN_ROLE) {
        GameEvent storage ev = currentEvents[id];
        require(ev.value > 0, "");
        require(block.timestamp > ev.finish, "");
        delete currentEvents[id];
        emit GameEventFinished(id);
    }

    /// @dev Calculate pending reward for GameEvent
    /// @param id - id of GameEvent
    /// @return expected reward
    function calcGamingReward(uint256 id) public view returns (uint256) {
        GameEvent storage ev = currentEvents[id];
        require(ev.value > 0, "");
        require(ev.start <= block.timestamp && block.timestamp <= ev.finish, "");
        return _calcGamingReward(ev);
    }

    /// @dev Calculate pending reward for GameEvent helper function
    /// @param ev - GameEvent to check
    /// @return expected reward
    function _calcGamingReward(GameEvent storage ev) internal view returns (uint256) {
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
        GameEvent storage ev,
        uint256 percent
    ) internal view returns (uint256) {
        for (uint256 i = 0; i < ev.thresholds.length; i++) {
            if (percent < ev.thresholds[i]) {
                return ev.values[i];
            }
        }
        return ev.values[ev.values.length - 1];
    }
}
