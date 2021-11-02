// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Event mint
 * @dev Contains functionality to handle mint for events in eterland game
 */
abstract contract Event {
    modifier notExceedEventSupply(uint256 _amount) {
        uint256 nextEventMinted = _totalEventSupplyMinted + _amount;
        require(nextEventMinted <= MAX_EVENTS_SUPPLY);
        _;
    }
    modifier mintDailyLimitEvent(uint256 _amount) {
        bool canMint = _lastMintTime == 0 ||
            block.timestamp > _lastMintTime + 1 days;

        require(canMint, "You can mint only once every day");
        require(_amount <= MAX_DAILY_MINT, "The amount exceed max daily mint");
        _;
    }

    uint256 private constant MAX_EVENTS_SUPPLY = 3000000 * uint256(10)**18;
    uint256 private _totalEventSupplyMinted = 0;

	/**
 	* @dev max daily mint (1% of total events supply)
 	*/
    uint256 private constant MAX_DAILY_MINT = 30000 * uint256(10)**18;
    uint256 private _lastMintTime = 0;

	/**
 	* @dev increment event supply if not exceed allowed daily amount and max supply 
 	*/
    function _incrementEventSupply(uint256 _amount)
        internal
        mintDailyLimitEvent(_amount)
        notExceedEventSupply(_amount)
    {
        _totalEventSupplyMinted += _amount;
        _lastMintTime = block.timestamp;
    }

    function getTotalEventMinted() public view returns (uint256) {
        return _totalEventSupplyMinted;
    }
}
