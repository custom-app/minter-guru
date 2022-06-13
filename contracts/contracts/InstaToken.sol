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
        uint256 released;                    // already released
        uint256 revokedAt;                   // revocation timestamp
        uint256 availableAfterRevocation;    // amount of tokens available to release after revocation
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

    // constants
    bytes32 public constant LIQUIDITY_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000001;
    bytes32 public constant VESTING_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000002;
    bytes32 public constant GAME_REWARD_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000003;
    uint256 public constant PERCENT_MULTIPLIER = 1000000;

    // token limits
    // liquidityTotalAmount + vestingTotalAmount + gameRewardTotalAmount = totalLimit
    uint256 public totalLimit;
    uint256 public liquidityTotalAmount;
    uint256 public vestingTotalAmount;
    uint256 public gameRewardTotalAmount;

    // spent tokens
    // liquiditySpent + vestingSpent + gameRewardSpent - burned = totalSupply()
    uint256 public liquiditySpent;
    uint256 public vestingSpent;
    uint256 public vestingPendingSpent;
    uint256 public gameRewardSpent;
    uint256 public burned;

    GameEvent public currentEvent;
    mapping(address => VestingRecord) public vestingRecords;

    modifier onlyStartedEvent() {
        require(hasStartedEvent(), ": started event not found");
        _;
    }

    modifier onlyNotStartedEvent() {
        require(!hasStartedEvent(), ": has started event");
        _;
    }

    /// @dev constructor
    /// @param _totalLimit -
    /// @param _liquidityAmount -
    /// @param _vestingAmount -
    /// @param _gameRewardAmount -
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
    /// @param _from - spending account
    /// @param _value - spending value
    function burnWithOptionalReturn(address _from, uint256 _value) external {
        uint256 rate = PERCENT_MULTIPLIER * burned / totalSupply();
        uint256 toReturn = (rate * _value) / PERCENT_MULTIPLIER;
        if (toReturn > _value / 2) {
            toReturn = _value / 2;
        }
        if (toReturn > 0) {
            if (toReturn > gameRewardSpent) {
                toReturn = gameRewardSpent;
            }
            transferFrom(_from, address(this), toReturn);
            gameRewardSpent -= toReturn;
        }
        _spendAllowance(_from, _msgSender(), _value - toReturn);
        _burn(_from, _value - toReturn);
    }

    function createVesting(
        address _receiver,
        uint256 _stepValue,
        uint256 _stepDuration,
        uint256 _steps
    ) external onlyRole(VESTING_ADMIN_ROLE) {
        require(_stepValue > 0, "");
        require(_stepDuration > 0, "");
        require(_steps > 0, "");
        require(vestingRecords[_receiver].stepValue == 0, "");
        require(vestingPendingSpent + _stepValue * _steps <= vestingTotalAmount, "");
        vestingRecords[_receiver] = VestingRecord(_receiver, _stepValue, _stepDuration, _steps, block.timestamp, 0, 0, 0);
        vestingPendingSpent += _stepValue * _steps;
    }

    function withdrawVesting(uint256 _value) external {
        VestingRecord storage record = vestingRecords[_msgSender()];
        require(record.stepValue > 0, "");
        require(_value <= vestingAvailableToRelease(), "");
        _mint(_msgSender(), _value);
        record.released += _value;
        if (record.released == record.stepValue*record.steps || record.released == record.availableAfterRevocation) {
            delete vestingRecords[_msgSender()];
        }
        vestingSpent += _value;
    }

    function revokeVesting(address _receiver) external onlyRole(VESTING_ADMIN_ROLE) {
        VestingRecord storage record = vestingRecords[_receiver];
        require(record.stepValue > 0, "");
        record.revokedAt = block.timestamp;
        record.availableAfterRevocation = record.stepValue * ((record.revokedAt - record.createdAt) / record.stepDuration);
        vestingPendingSpent -= (record.stepValue * record.steps - record.availableAfterRevocation);
        if (record.availableAfterRevocation == record.released) {
            delete vestingRecords[_receiver];
        }
    }

    function vestingAvailableToRelease() public view returns (uint256) {
        VestingRecord storage record = vestingRecords[_msgSender()];
        require(record.stepValue > 0, "");
        uint256 rightBound = block.timestamp;
        if (record.revokedAt > 0) {
            rightBound = record.revokedAt;
        }
        return record.stepValue * ((rightBound - record.createdAt) / record.stepDuration) - record.released;
    }

    function createEvent(
        uint256 _value,
        uint256 _start,
        uint256 _finish,
        uint256[] memory _thresholds,
        uint256[] memory _values
    ) external onlyRole(GAME_REWARD_ADMIN_ROLE) onlyNotStartedEvent {
        require(_start < _finish, "");
        require(_value < gameRewardTotalAmount - gameRewardSpent, "");
        require(_thresholds.length + 1 == _values.length, "");
        currentEvent = GameEvent(_value, _start, _finish, _thresholds, _values, 0);
    }

    function mintGamingAward(
        address _to
    ) external onlyRole(GAME_REWARD_ADMIN_ROLE) onlyStartedEvent {
        uint256 value = calcGamingReward();
        _mint(_to, value);
        gameRewardSpent += value;
        currentEvent.currentSupply += value;
    }

    function calcGamingReward() public onlyStartedEvent view returns (uint256) {
        if ((10 * (block.timestamp - currentEvent.start)) / (currentEvent.finish - currentEvent.start) < 2) {
            return findGamingReward(PERCENT_MULTIPLIER);
        }
        uint256 eventRate = currentEvent.currentSupply * PERCENT_MULTIPLIER /
        ((currentEvent.value * (block.timestamp - currentEvent.start)) / (currentEvent.finish - currentEvent.start));
        return findGamingReward(eventRate);
    }

    function findGamingReward(uint256 _percent) internal view returns (uint256) {
        for (uint256 i = 0; i < currentEvent.thresholds.length; i++) {
            if (_percent < currentEvent.thresholds[i]) {
                return currentEvent.values[i];
            }
        }
        return currentEvent.values[currentEvent.values.length - 1];
    }

    function hasStartedEvent() internal view returns (bool) {
        return currentEvent.start <= block.timestamp &&
        block.timestamp <= currentEvent.finish &&
        currentEvent.value != currentEvent.currentSupply;
    }
}
