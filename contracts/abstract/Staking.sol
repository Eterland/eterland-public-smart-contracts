// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * @title Stacking mint
 * @dev Contains functionality to handle mint for stacking
 */
abstract contract Staking {
    uint256 private constant MAX_STAKING_SUPPLY = 15000000 * uint256(10)**18;
    uint256 private _totalStakingMinted = 0;
    uint256 private constant MAX_DAILY_MINT = 150000 * uint256(10)**18;
    uint256 private _lastMintTime = 0;
    modifier notExceedStakingSupply(uint256 _amount) {
        uint256 nextStakingMinted = _totalStakingMinted + _amount;
        require(nextStakingMinted <= MAX_STAKING_SUPPLY);
        _;
    }
    modifier mintDailyLimitStaking(uint256 _amount) {
        bool canMint = _lastMintTime == 0 ||
            block.timestamp > _lastMintTime + 1 days;

        require(canMint, "You can mint only once every day");
        require(_amount <= MAX_DAILY_MINT, "The amount exceed max daily mint");
        _;
    }


 	/**
 	* @dev increment staking supply if not exceed allowed daily amount and max supply 
 	*/
    function _increaseTotalStakingMinted(uint256 _amount)
        internal
        notExceedStakingSupply(_amount)
        mintDailyLimitStaking(_amount)
    {
        _totalStakingMinted += _amount;
        _lastMintTime = block.timestamp;
    }

    function getTotalStakingMinted() public view returns (uint256) {
        return _totalStakingMinted;
    }
}
