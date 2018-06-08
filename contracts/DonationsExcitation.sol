pragma solidity ^0.4.23;

import "./math/SafeMath.sol";
import "./SFOXToken.sol";

/// @title DonationsExcitation - vault of takens allocated

contract DonationsExcitation {
    using SafeMath for uint256;
    // Total number of allocations to distribute additional tokens
    address allocationAccount;
    uint256 public totalAllocations;
    uint256 private releasedCount;

    uint private reducePeriod = 1 minutes;//2 * 12 * 30 days;
    uint private initRelease = 30000;
    uint private releasePeriod = 30 seconds;// 1 days;

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
        releasedCount = releasedCount.add(toTransfer);
        return true;
    }

    function getLockBalance() public view returns (uint256 balance) {
        return getBalance() - getReleaseBalance();
    }

    function getReleaseBalance() public view returns (uint256 balance) {
        uint subTime = now.sub(createTime);

        uint releaseCount = reducePeriod.div(releasePeriod);
        uint256 totalRelease;
        uint curRelease = initRelease;
        for(uint i = 0; i < subTime.div(reducePeriod) + 1; i++) {
            if(i != 0 && i % releaseCount == 0){
                curRelease = curRelease.div(2);
            }
            totalRelease = totalRelease.add(curRelease);
        }
        
        if(totalRelease > totalAllocations){
            totalRelease = totalAllocations;
        }
        return totalRelease;
    }

    function getBalance() public view returns(uint256 balance) {
        return totalAllocations - releasedCount;
    }
}