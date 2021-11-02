// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Liquidity Mint
 * @dev Stores liquidity mint status
 */
abstract contract Liquidity {
    uint256 public totalLiquidityMinted = 0;

    uint256 private constant MAX_LIQUIDITY_SELL = 30000000 * uint256(10)**18;

    modifier notExceedLiquiditySupply(uint256 _amount) {
        uint256 nextLiquidityMinted = totalLiquidityMinted + _amount;
        require(nextLiquidityMinted <= MAX_LIQUIDITY_SELL);
        _;
    }
}
