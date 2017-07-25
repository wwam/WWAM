pragma solidity ^0.4.6;

import "./ERC20.sol";
import "./Ownable.sol";
import './StandardToken.sol';
import "./SafeMath.sol";

/**
 * A token that can be revoked before then end of the crowdsale.
 */
contract WWAMBountyToken is StandardToken, Ownable {

  /** List of agents that are allowed to revoke tokens */
  mapping (address => bool) public bountyAgents;
  
  event BountyAgentChanged(address addr, bool state  );
  
  /*
  * Function to revoke tokens in case the terms and conditions of the bounty campaign are violated by an user after tokens were assigned
  */
  function revokeTokens(address receiver, uint tokenAmount) onlyBountyAgent {
      if (balances[receiver] >= tokenAmount) {
	    totalSupply = safeSub(totalSupply, tokenAmount);
	    balances[receiver] = safeSub(balances[receiver], tokenAmount);
      }
  }
  
   /**
   * Owner can allow a crowdsale contract to revoke tokens.
   */
  function setBountyAgent(address addr, bool state) onlyOwner public {
    bountyAgents[addr] = state;
    BountyAgentChanged(addr, state);
  }
  
  modifier onlyBountyAgent() {
    // Only crowdsale contracts are allowed to revoke tokens
    if(!bountyAgents[msg.sender]) {
        throw;
    }
    _;
  }
  
}
