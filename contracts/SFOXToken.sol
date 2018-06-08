pragma solidity ^0.4.21;

import "./token/ERC20/StandardToken.sol";
import "./AuthorityManaged.sol";
import "./TeamExcitation.sol";
import "./DonationsExcitation.sol";

contract SFOXToken is StandardToken, AuthorityManaged {
    /**
        Token info
    */
    string constant public name = "SFOX";
    uint8 constant  public decimals = 18;
    string constant public symbol = "SF";

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
        child contracts address
     */
    DonationsExcitation public donationsExcitationContract;
    TeamExcitation public teamExcitationContract;

    function SFOXToken(
        uint256 _initialAmount,
        address _foundationAddress, 
        address _counselorAddress,
        address _teamAccount,
        address _donationsAccount,
        address _promotionAccount
    ) public {
        totalSupply_ = _initialAmount * 10 ** uint256(decimals);
        
        //uint256 ICOAmount = _initialAmount / maxDivisor * ICOProfit;
        uint256 donationsExcitationAmount = totalSupply_ / maxDivisor * excitationProfit;
        uint256 teamExcitationAmount = totalSupply_ / maxDivisor * teamProfit;

        donationsExcitationContract = new DonationsExcitation(this, _donationsAccount, donationsExcitationAmount);
        teamExcitationContract = new TeamExcitation(this, _teamAccount, teamExcitationAmount);

        balances[msg.sender] = totalSupply_ / maxDivisor * ICOProfit;
        balances[_promotionAccount] = totalSupply_ / maxDivisor * promotionProfit;
        balances[_foundationAddress] = totalSupply_ / maxDivisor * foundationProfit;
        balances[_counselorAddress] = totalSupply_ / maxDivisor * counselorProfit;
        balances[teamExcitationContract] = teamExcitationAmount;
        balances[donationsExcitationContract] = donationsExcitationAmount;
    }
}
