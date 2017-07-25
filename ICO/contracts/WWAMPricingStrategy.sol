pragma solidity ^0.4.6;

import "./PricingStrategy.sol";
import "./Crowdsale.sol";
import "./Ownable.sol";

/**
 * Fixed crowdsale pricing - everybody gets the same price.
 */
contract WWAMPricingStrategy is PricingStrategy, Ownable, SafeMath {

  uint round1BeginsAt;
  uint round2BeginsAt;
  uint finalRoundBeginsAt;
  uint baseRate = 5000000000000; //wei per WWAM
  
  enum CurrentRound { Round1, Round2, Final }
  
  function WWAMPricingStrategy(uint _round1BeginsAt, uint _round2BeginsAt, uint _finalRoundBeginsAt) {
	round1BeginsAt = _round1BeginsAt;
	round2BeginsAt = _round2BeginsAt;
	finalRoundBeginsAt = _finalRoundBeginsAt;
  }
  
  function getCurrentRound() public returns (CurrentRound){
	  if (now < round2BeginsAt)
		  return CurrentRound.Round1;
	  else if (now < finalRoundBeginsAt)
		  return CurrentRound.Round2;
	  return CurrentRound.Final;
  }
  
  function tokensToWei(uint tokens) public constant returns (uint) {
	return safeMul(tokens, baseRate);
  }
  
  /**
   * Calculate the current price for buy in amount.
   *
   */
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint) {
	//Minimum investment is 10 finney
	if (value < 10 finney) 
		return 0;
	//15% Bonus for Round1 investors
	if (getCurrentRound() == CurrentRound.Round1)
		return safeMul(safeDiv(safeDiv(value, baseRate), 100), 115);
	//10% Bonus for Round2 investors
	else if (getCurrentRound() == CurrentRound.Round2)
		return safeMul(safeDiv(safeDiv(value, baseRate), 100), 110);
	//Base rate for Final Round investors
	return value / baseRate;
  }

}