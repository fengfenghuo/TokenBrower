pragma solidity ^0.4.23;

import "./math/SafeMath.sol";
import "./SFOXToken.sol";

/// @title DonationsExcitation - vault of takens allocated

contract DonationsExcitation {
    using SafeMath for uint256;
    // Total number of allocations to distribute additional tokens
    address allocationAccount;
    uint256 public totalAllocations;

    uint private reducePeriod = 1 minutes;//2 * 12 * 30 days;
    uint private initRelease = 30000;

    uint256 public createTime;

    SFOXToken public token;
    
    function DonationsExcitation (
        SFOXToken _token,
        address _allocationAccount, 
        uint256 _totalAllocations
    ) public {
        token = _token;
        allocationAccount = _allocationAccount;
        createTime = now;
        totalAllocations = _totalAllocations;
    }

    function release() public returns (bool) {
        uint256 toTransfer = getReleaseBalance();
        if(toTransfer == 0) return false;

        if(!token.transfer(allocationAccount, toTransfer)) return false;
        return true;
    }

    function getLockBalance() public view returns (uint256 balance) {
        return token.balanceOf(this) - getReleaseBalance();
    }

    function getReleaseBalance() public view returns (uint256 balance) {
        uint subTime = now.sub(createTime);
        uint period = subTime.div(reducePeriod).mul(2);
        uint curRelease = initRelease;
        if (period > 0){
            curRelease = curRelease.div(period);
        }
        
        return curRelease.mul(subTime.div(1 days)) - totalAllocations - token.balanceOf(this);
    }
}