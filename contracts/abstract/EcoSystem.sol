// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ecosystem mint
 * @dev Contains functionality to handle mint for eterland game ecosystem
 */
abstract contract EcoSystem {
	uint256 constant private MAX_ECOSYSTEM_SUPPLY = 210000000 * uint256(10)**18;
	
	/**
 	* @dev stores ecosystem minted amount
 	*/
	uint256 private _currentEcosystemSupply = 0;
	/**
 	* @dev stores timestamp for first mint 
 	*/
	uint256 internal _firstEcosystemMintTimeStamp = 0; 

	uint256 private _ecosystemHalvingTime =30 days;
	
	/**
 	* @dev stores first period monthly ecosystem supply 
 	*/
	uint256 internal _firstEcosystemPeriodSupply = MAX_ECOSYSTEM_SUPPLY * 2 / 100;

	/**
 	* @dev stores minimum amount for monthly ecosystem supply 
 	*/
	uint256 constant private MINIMUM_ECOSYSTEM_SUPPLY = 2250000 * uint256(10)**18;


	modifier canIncrementEcosystemSupply(uint256 _amount){
		uint256 nextEcosystemSupply = _currentEcosystemSupply + _amount;
		require(nextEcosystemSupply <= MAX_ECOSYSTEM_SUPPLY,string(
		abi.encodePacked("The max ecosystem supply is: ",MAX_ECOSYSTEM_SUPPLY)));
		require(nextEcosystemSupply <= getTotalEcosystemMint(),
		"can't mint that value yet");
		_;
	}

	/**
 	* @dev increment ecosystem supply if not exceed allowed amount at block time
 	*/
	function incrementEcosystemSupply(uint256 _amount) internal 
	canIncrementEcosystemSupply(_amount) {
		if(_firstEcosystemPeriodSupply == 0){
			_firstEcosystemMintTimeStamp = block.timestamp;
		}
		
        _currentEcosystemSupply += _amount;

	}

	/**
 	* @dev getter for ecosystem supply
 	*/
	function getEcosystemSupply() external view returns(uint256){
		return _currentEcosystemSupply;
	}

	/**
 	* @dev getter for allowed mint amount at block time
 	*/
	function getAvailableEcosystemMint() public view returns (uint256){
		return getTotalEcosystemMint() - _currentEcosystemSupply;
	}
	
	/**
 	* @dev get total allowed mint at block time(updated daily), will include minted amount and available amount to mint
 	* this derease the available monthly mint by 1.7 % from previus period mint
	* the time required to mint all ecosystem tokens is 6 years 5 month and 21 days since the first ecosystem mint
	* for some examples of minted tokens take a look to the unit tests at the repository
	*
	*/
    function getTotalEcosystemMint() public view returns(uint256){
		
		uint256 currentPeriodSupply = _firstEcosystemPeriodSupply;
 		uint256 availableForMint = getDailyHalving(currentPeriodSupply);
		if(isTheFirstEcosystemMint())
		{	
			return availableForMint;
		} 

        uint256 secondsSinceFirstMint =  getSecondsSinceFirstEcosystemMint();
       
         
		
        uint256 monthsSinceFirstEcosystemMint = secondsSinceFirstMint / _ecosystemHalvingTime;

		 
		 for(uint256 index = 0 ; index < monthsSinceFirstEcosystemMint ; index ++){
            availableForMint += currentPeriodSupply;
            currentPeriodSupply = updatePeriodSupply(currentPeriodSupply);
        }
        
        uint256 currentDailyRetribution = getDailyHalving(currentPeriodSupply);
        
        uint256 remainingDays = (secondsSinceFirstMint % _ecosystemHalvingTime) / 1 days; 
        
        availableForMint += remainingDays * currentDailyRetribution;
        
		if(availableForMint > MAX_ECOSYSTEM_SUPPLY){
			return MAX_ECOSYSTEM_SUPPLY;
		}
        
        return availableForMint;
    }

	/**
 	* @dev decrease 1.7% to the current period supply
	*/
	function updatePeriodSupply(uint256 periodSupply) internal pure returns(uint256){
		periodSupply = periodSupply * 983 / 1000;

		return periodSupply < MINIMUM_ECOSYSTEM_SUPPLY ? 
                MINIMUM_ECOSYSTEM_SUPPLY : periodSupply;
	}

	/**
 	* @dev convert monthly supply into daily supply
	*/
	function getDailyHalving(uint256 periodSupply) internal pure returns (uint256){
		return periodSupply / 30;
	}

	function isTheFirstEcosystemMint() internal view returns (bool){
		return _firstEcosystemMintTimeStamp == 0;
	}

	/**
 	* @dev get seconds since the first ecosystem mint
	*/
    function getSecondsSinceFirstEcosystemMint() public view returns(uint256){
            
        if(_firstEcosystemMintTimeStamp == 0)
        {
                return 0;
        }
        return block.timestamp - _firstEcosystemMintTimeStamp;
    }

}