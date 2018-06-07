pragma solidity ^0.4.23;

import "./math/SafeMath.sol";
import "./SFOXToken.sol";

/// @title TeamExcitation - Time-locked vault of takens allocated ß

contract TeamExcitation {
    using SafeMath for uint256;
    // Total number of allocations to distribute additional tokens
    address allocationAccount;
    uint256 public totalAllocations;

    uint private maxProfit = 10000;
    uint private perUnlockProfit = 500;
    
    uint256 public createTime;
    uint256 public lockedTime;

    SFOXToken token;

    function TeamExcitation (
        SFOXToken _token,
        address _allocationAccount, 
        uint256 _totalAllocations, 
        uint256 _lockedTime
    ) public {
        token = _token;
        allocationAccount = _allocationAccount;
        lockedTime = _lockedTime;
        createTime = now;
        totalAllocations = _totalAllocations;
    }

    function issuse(uint256 value) public returns (bool) {
        if(!token.transfer(allocationAccount, value)) {
            revert();
            return false;
        }
        return true;
    }

    function unlock() public returns (bool) {
        if(now > createTime + lockedTime) return false;

        uint256 toTransfer = getUnlockBalance();
        if(toTransfer == 0) return false;

        if(!token.transfer(allocationAccount, toTransfer)) {
            revert();
            return false;
        }
        return true;
    }

    function getBalance() public view returns (uint256 balance) {
        return token.balanceOf(this);
    }

    function getLockBalance() public view returns (uint256 balance) {
        return getBalance() - getUnlockBalance();
    }

    function getUnlockBalance() public view returns (uint256 balance) {
        if(now < createTime + lockedTime) return 0;

        uint count = now.sub(createTime).div(30 days) + 1;
        return getBalance().mul(perUnlockProfit.mul(count)).div(maxProfit);
    }
}