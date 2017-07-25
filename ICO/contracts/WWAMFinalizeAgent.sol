pragma solidity ^0.4.6;

import "./Crowdsale.sol";
import "./CrowdsaleToken.sol";
import "./Ownable.sol";

/**
 * Finalize the ICO process by unlocking transfer for sold tokens and generate the team share.
 */
contract WWAMFinalizeAgent is FinalizeAgent, Ownable {

  CrowdsaleToken public token;
  Crowdsale public crowdsale;

  function WWAMFinalizeAgent(CrowdsaleToken _token, Crowdsale _crowdsale) {
    token = _token;
    crowdsale = _crowdsale;
  }

  function isSane() public constant returns (bool) {
    return true;
  }

   /*
   * Generating 1% of total crowdsale token for the team
   */
  function createTeamTokens() private {
	  uint teamTokens = crowdsale.tokensSold() / 100;
	  token.mint(owner, teamTokens);
  }
  
  /*
  * Called by crowdsale finalize() 
  */
  function finalizeCrowdsale() public {
	  if (msg.sender != address(crowdsale) && msg.sender != owner)
		throw;
	  //Generating team part
	  createTeamTokens();
	  
	  //Allowing the token to be transfered
      token.releaseTokenTransfer();
  }

}