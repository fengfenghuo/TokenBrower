pragma solidity ^0.4.23;

import "./math/SafeMath.sol";
import "./SFOXToken.sol";

/// @title TeamExcitation - Time-locked vault of takens allocated ß

contract TeamExcitation {
    using SafeMath for uint256;
    // Total number of allocations to distribute additional tokens
    address allocationAccount;
    uint256 public totalAllocations;
    uint256 private releasedCount;

    uint private maxProfit = 10000;
    uint private perUnlockProfit = 500;
    
    uint256 public createTime;
    uint private period = 60 seconds; //30 days;
    uint public lockedTime = 0 * period;//20;

    SFOXToken token;

    function TeamExcitation (
        SFOXToken _token,
        address _allocationAccount, 
        uint256 _totalAllocations
    ) public {
        token = _token;
        allocationAccount = _allocationAccount;
        createTime = now;
        totalAllocations = _totalAllocations;
    }

    function unlock() public returns (bool) {
        if(now < createTime + lockedTime) return false;

        uint256 toTransfer = getUnlockBalance();
        if(toTransfer == 0) return false;

        if(!token.transfer(allocationAccount, toTransfer)) return false;
        releasedCount = releasedCount.add(toTransfer);
        return true;
    }

    function getBalance() public view returns (uint256 balance) {
        return totalAllocations - releasedCount;
    }

    function getLockBalance() public view returns (uint256 balance) {
        return getBalance() - getUnlockBalance();
    }

    function getUnlockBalance() public view returns (uint256 balance) {
        if(now < createTime + lockedTime) return 0;

        uint count = now.sub(createTime).div(period) + 1;
        return getBalance().mul(perUnlockProfit.mul(count)).div(maxProfit);
    }
}