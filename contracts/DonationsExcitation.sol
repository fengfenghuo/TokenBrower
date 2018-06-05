pragma solidity ^0.4.23;

import "./math/SafeMath.sol";
import "./VBToken.sol";

/// @title DonationsExcitation - vault of takens allocated ß

contract DonationsExcitation {
    using SafeMath for uint256;

    // Total number of allocations to distribute additional tokens
    uint256 totalAllocations;

    mapping(address => uint256) balances;

    uint public initDonationsPer = 200000;
    uint256 public periodicTime = 24 * 30 days;
    uint public maxProfit = 10000;
    uint public scalage = 5000;

    VBToken token;

    function DonationsExcitation (
        uint256 _totalAllocations 
    ) public {
        token = VBToken(msg.sender);
        totalAllocations = _totalAllocations;
    }
}