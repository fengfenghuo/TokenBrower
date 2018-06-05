pragma solidity ^0.4.23;

import "./math/SafeMath.sol";
import "./VBToken.sol";

/// @title TeamExcitation - Time-locked vault of takens allocated ß

contract TeamExcitation {
    using SafeMath for uint256;
    // Total number of allocations to distribute additional tokens
    address allocationAccount;
    uint256 totalAllocations;

    uint private maxProfit = 10000;
    uint private perUnlockProfit = 500;
    
    uint256 public createTime;
    uint256 public lockedTime;

    VBToken token;

    function TeamExcitation (
        address _allocationAccount, 
        uint256 _totalAllocations, 
        uint256 _lockedTime
    ) public {
        token = VBToken(msg.sender);
        allocationAccount = _allocationAccount;
        lockedTime = _lockedTime;
        createTime = now;
        totalAllocations = _totalAllocations;
    }

    function unlock() public returns (bool) {
        if(now > createTime + lockedTime) return false;

        uint256 toTransfer = getUnlockBalance();
        if(toTransfer == 0) return false;

        if(!token.transfer(allocationAccount, toTransfer)) return false;
        totalAllocations = totalAllocations.sub(toTransfer);
        return true;
    }

    function getLockBalance() public view returns (uint256 balance) {
        return totalAllocations - getUnlockBalance();
    }

    function getUnlockBalance() public view returns (uint256 balance) {
        if(now < createTime + lockedTime) return 0;

        var count = now.sub(createTime).div(30 days) + 1;
        return totalAllocations.mul(perUnlockProfit.mul(count)).div(maxProfit);
    }
}