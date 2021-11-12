// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./ERC20VestingWallet.sol";  

/**
 * @title TeamVesting
 * @dev Handle 3 year vesting for ERC20 tokens. 
 */ 
contract TeamVesting is ERC20VestingWallet{

	constructor(address to) ERC20VestingWallet(to, 365 days * 3){
		require(to != address(this));
	}
	/**
	  @dev Getter for historical balance 
	 */
	function getHistoricalBalance(address token) public view returns (uint256){
		return _historicalBalance(token);
	}

}