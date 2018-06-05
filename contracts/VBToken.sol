pragma solidity ^0.4.23;

import "./token/ERC20/StandardToken.sol";
import "./AuthorityManaged.sol";
import "./TeamExcitation.sol";
import "./DonationsExcitation.sol";

contract VBToken is StandardToken, AuthorityManaged {
    /**
        Token info
    */
    string constant public name = "XToken";
    uint8 constant  public decimals = 8;
    string constant public symbol = "XT";

    /**
        profit
    */
    uint constant private maxDivisor = 10000;
    uint private ICOProfit = 1000;
    uint private excitationProfit = 4000;
    uint private teamProfit = 1500;
    uint private foundationProfit = 1500;
    uint private promotionProfit = 1000;
    uint private counselorProfit = 1000;

    /**
        config
    */ 
    uint256 teamExcitationLockTime = 20 * 30 days;

    /**
        child contracts address
     */
    DonationsExcitation public donationsExcitationContract;
    TeamExcitation public teamExcitationContract;

    function VBToken(
        uint256 _initialAmount,
        address _foundationAddress, 
        address _counselorAddress,
        address _teamAccount,
        address _promotionAccount
    ) public {
        totalSupply_ = _initialAmount * 10 ** uint256(decimals);
        
        //uint256 ICOAmount = _initialAmount / maxDivisor * ICOProfit;
        uint256 donationsExcitationAmount = totalSupply_ / maxDivisor * excitationProfit;
        uint256 teamExcitationAmount = totalSupply_ / maxDivisor * teamProfit;

        donationsExcitationContract = new DonationsExcitation(donationsExcitationAmount);
        teamExcitationContract = new TeamExcitation(_teamAccount, teamExcitationAmount, teamExcitationLockTime);

        balances[msg.sender] = totalSupply_ / maxDivisor * ICOProfit;
        balances[_promotionAccount] = totalSupply_ / maxDivisor * promotionProfit;
        balances[_foundationAddress] = totalSupply_ / maxDivisor * foundationProfit;
        balances[_counselorAddress] = totalSupply_ / maxDivisor * counselorProfit;
        balances[teamExcitationContract] = teamExcitationAmount;
        balances[donationsExcitationContract] = donationsExcitationAmount;
    }
}
