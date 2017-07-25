pragma solidity ^0.4.7;

import "./Crowdsale.sol";
import "./WWAMPricingStrategy.sol";
import "./WWAMBountyToken.sol";
import "./MintableToken.sol";


contract WWAMCrowdsale is Crowdsale {
  
  /* The maximum amount the crowdsale can raise */
  uint investmentCapInWei = 500000000000000000000000; // 500000 ETH 
  
  /* The number of tokens awarded for bounty campaign */
  uint public bountyTokens = 0;
  
  /* Public list of bounty rewards */
  mapping (address => uint256) public bountyRewards;
	
  function WWAMCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end)
    Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, 500000000000000000000) { //Minimum funding goal of 500 ETH
  }

   /**
   * Function allowing to credit tokens to participant in the bounty campaign
   */
  function assignBountyTokens(address receiver, uint tokenAmount) onlyOwner {
	  uint bountyWeiAmount = WWAMPricingStrategy(pricingStrategy).tokensToWei(tokenAmount);
	  uint totalBountyWeiAmount = WWAMPricingStrategy(pricingStrategy).tokensToWei(bountyTokens);
	  
	  //Making sure we do not exceed the 1% of maximum investment allocated for the bounty campaign
	  if (safeAdd(bountyWeiAmount, totalBountyWeiAmount) >= (investmentCapInWei / 100))
		  throw;
	  
	  bountyRewards[receiver] = safeAdd(bountyRewards[receiver], tokenAmount);
	  bountyTokens = safeAdd(bountyTokens, tokenAmount);
	  
	  assignTokens(receiver, tokenAmount);
  }
  
  /*
  * Function to revoke tokens in case the terms and conditions of the bounty campaign are violated by an user after tokens were assigned
  */
  function revokeBountyTokens(address receiver, uint tokenAmount) onlyOwner {
	  //Checking that we can only revoke tokens of a bounty campaign participant. Also making sure that we do not end up with a negative blaance
	  if (bountyRewards[receiver] < tokenAmount)
		  throw;
	  bountyTokens = safeSub(bountyTokens, tokenAmount);
	  bountyRewards[receiver] = safeSub(bountyRewards[receiver], tokenAmount);
	  
	  WWAMBountyToken bountyToken = WWAMBountyToken(token);
	  bountyToken.revokeTokens(receiver, tokenAmount);
  }
  
  /**
   * Checking that we do not exceed the investment cap.
   */
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool) {
    return weiRaisedTotal > investmentCapInWei;
  }

  /**
   * Condition is the same as above
   */
  function isCrowdsaleFull() public constant returns (bool) {
    return weiRaised >= investmentCapInWei;
  }

  /**
   * Creating new tokens for the investor and assigning them
   */
  function assignTokens(address receiver, uint tokenAmount) private {
    MintableToken mintableToken = MintableToken(token);
    mintableToken.mint(receiver, tokenAmount);
  }

}