// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title ContentCreator mint
 * @dev Contains functionality to handle mint for content creators
 */
abstract contract ContentCreator {
    uint256 private constant MAX_CONTENT_CREATORS_SUPPLY =
        3000000 * uint256(10)**18;
    uint256 private _totalContentCreatorMinted = 0;
    uint256 private constant MAX_DAILY_MINT = 30000 * uint256(10)**18;
    uint256 private _lastMintTime = 0;

    modifier notExceedContentCreatorSupply(uint256 _amount) {
        uint256 nextContentCreatorMinted = _totalContentCreatorMinted +
            _amount;
        require(nextContentCreatorMinted <= MAX_CONTENT_CREATORS_SUPPLY);
        _;
    }
	
    modifier mintDailyLimitContentCreators(uint256 _amount) {
        bool canMint = _lastMintTime == 0 ||
            block.timestamp > _lastMintTime + 1 days;

        require(canMint, "You can mint only once every day");
        require(_amount <= MAX_DAILY_MINT, "The amount exceed max daily mint");
        _;
    }

    /**
     * @dev increase total content creator minted amount and update lastMintTime
     */
    function increaseTotalContentCreatorMinted(uint256 _amount)
        internal
        notExceedContentCreatorSupply(_amount)
        mintDailyLimitContentCreators(_amount)
    {
        _totalContentCreatorMinted += _amount;
        _lastMintTime = block.timestamp;
    }

    function getTotalContentCreatorMinted() public view returns (uint256) {
        return _totalContentCreatorMinted;
    }
}
