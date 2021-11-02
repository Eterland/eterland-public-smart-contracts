// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * @title Moderator mint
 * @dev Contains functionality to handle mint for Moderators
 */
abstract contract Moderator {
    uint256 private constant MAX_MOD_SUPPLY = 300000 * uint256(10)**18;
    uint256 private constant MAX_DAILY_MINT = 3000 * uint256(10)**18;
    uint256 private _totalModeratorMinted = 0;
    uint256 private _lastMintTime = 0;
    modifier notExceedModeratorSupply(uint256 _amount) {
        uint256 nextModeratorMinted = _totalModeratorMinted + _amount;
        require(nextModeratorMinted <= MAX_MOD_SUPPLY);
        _;
    }
    
    modifier mintDailyLimitModerator(uint256 _amount) {
        bool canMint = _lastMintTime == 0 ||
            block.timestamp > _lastMintTime + 1 days;

        require(canMint, "You can mint only once every day");
        require(_amount <= MAX_DAILY_MINT, "The amount exceed max daily mint");
        _;
    }

 	/**
 	* @dev increment moderator supply if not exceed allowed daily amount and max supply 
 	*/
    function _incrementModeratorSupply(uint256 _amount) 
    mintDailyLimitModerator(_amount)
    notExceedModeratorSupply(_amount)
    internal 
    {
        _totalModeratorMinted += _amount;
        _lastMintTime = block.timestamp;
    }

    function getTotalModeratorMinted() public view returns(uint256){
        return _totalModeratorMinted;
    }


  
}
