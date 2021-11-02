// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./abstract/EcoSystem.sol";
import "./abstract/EterAccessControl.sol";
import "./abstract/Liquidity.sol";
import "./abstract/Moderator.sol";
import "./abstract/Staking.sol";
import "./abstract/Event.sol";
import "./abstract/ContentCreator.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ETER is
    ERC20,
    EterAccessControl,
    ContentCreator,
    EcoSystem,
    Moderator,
    Liquidity,
    Staking,
    Event
{
    modifier notExceedMaximumSupply(uint256 _amount) {
        uint256 nextSupply = totalMinted + _amount;
        require(
            nextSupply < MAX_SUPPLY,
            "The transaction exceed maximum supply"
        );
        _;
    }

    uint256 public constant MAX_SUPPLY = 300000000 * _baseMultiplier;

    uint256 public totalMinted = 0;

    uint256 private constant _baseMultiplier = uint256(10)**18;

    uint256 private constant MAX_TEAM_SUPPLY = 26700000 * _baseMultiplier;

    uint256 private constant MAX_PRIVATE_SALE_SELL = 12000000 * _baseMultiplier;

    uint256 public totalBurn = 0;

   	/*
		set all team members as administrators and mint private sell and team supply 
		team supply will have a vesting for 3 years
    */
    constructor(address COO, address CEO, address CFO, address INV1, address INV2) ERC20("ETER","ETER")  EterAccessControl(4){
        //Mint team supply
        _mint(msg.sender, MAX_TEAM_SUPPLY);
        totalMinted += MAX_TEAM_SUPPLY;

        //Mint private sell
        _mint(msg.sender, MAX_PRIVATE_SALE_SELL);
        totalMinted += MAX_PRIVATE_SALE_SELL;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, CEO);
        _setupRole(DEFAULT_ADMIN_ROLE, COO);
		_setupRole(DEFAULT_ADMIN_ROLE, CFO);
		_setupRole(DEFAULT_ADMIN_ROLE, INV1);
		_setupRole(DEFAULT_ADMIN_ROLE, INV2);
    }

	
    /**
     * @dev create amount of new tokens for the message sender from the ecosystem

	 	Requirements:
		- the caller must have the `ECOSYSTEM_MINTER_ROLE`.
		- the amount to mint must be less or equal than max mint in the block time 
		(for more info see at ecosystem.sol) 
		- the amount can't exceed max supply
     */
    function mintEcosystem(uint256 _amount)
        public
        hasEcosystemMinterRole
        notExceedMaximumSupply(_amount)
    {
        require(msg.sender != address(0), "cannot mint to zero address");
        incrementEcosystemSupply(_amount);
        _mint(msg.sender, _amount);
        totalMinted += _amount;
    }
	/**
     * @dev create amount of new tokens for the message sender from the 
	 (liquidity - public sell) tokens

	 	Requirements:
		- the caller must have the `LIQUIDITY_MINTER_ROLE`.
		- the amount must be less or equal than MAX_LIQUIDITY_SUPPLY
		- the amount must be less or equal than MAX_SUPPLY
     */

    function mintLiquidity(uint256 _amount)
        public
        hasLiquidityMinterRole
        notExceedLiquiditySupply(_amount)
        notExceedMaximumSupply(_amount)
    {
        require(msg.sender != address(0), "cannot mint to zero address");
        _mint(msg.sender, _amount);
        totalMinted += _amount;
        totalLiquidityMinted += _amount;
    }
	/**
     * @dev create amount of new tokens for the message sender from the 
	 moderator tokens

	 	Requirements:
		- the caller must have the `MOD_MINTER_ROLE`.
		- the amount must be less or equal than the MAX_DAILY_MINT for moderators 
		- the amount must be less or equal than MAX_SUPPLY
     */
    function mintModerator(uint256 _amount)
        public
        hasModeratorRole
        notExceedMaximumSupply(_amount)
    {
        require(msg.sender != address(0), "cannot mint to the zero address");
        _incrementModeratorSupply(_amount);
        _mint(msg.sender, _amount);
        totalMinted += _amount;
    }

	/**
     * @dev create amount of new tokens for the message sender from the 
	 staking tokens

	 	Requirements:
		- the caller must have the `STAKING_MINTER_ROLE`.
		- the amount must be less or equal than the MAX_DAILY_MINT for staking 
		- the amount must be less or equal than MAX_SUPPLY
     */
    function mintStaking(uint256 _amount)
        public
        hasStakingRole
        notExceedMaximumSupply(_amount)
    {
        require(msg.sender != address(0), "cannot mint to the zero address");
        _increaseTotalStakingMinted(_amount);
        _mint(msg.sender, _amount);
        totalMinted += _amount;
    }

	/**
     * @dev create amount of new tokens for the message sender from the 
	 event tokens

	 	Requirements:
		- the caller must have the `EVENTS_MINTER_ROLE`.
		- the amount must be less or equal than the MAX_DAILY_MINT for events 
		- the amount must be less or equal than MAX_SUPPLY
     */
    function mintEvent(uint256 _amount)
        public
        hasEventMinterRole
        notExceedMaximumSupply(_amount)
    {
        require(msg.sender != address(0), "cannot mint to the zero address");
        _incrementEventSupply(_amount);
        _mint(msg.sender, _amount);
		totalMinted += _amount;
    }

	/**
     * @dev create amount of new tokens for the message sender from the 
	 content creator tokens

	 	Requirements:
		- the caller must have the `CONTENT_CREATORS_MINTER_ROLE`.
		- the amount must be less or equal than the MAX_DAILY_MINT for content creators 
		- the amount must be less or equal than MAX_SUPPLY
     */
    function mintContentCreator(uint256 _amount)
        public
        hasContentCreatorRole
        notExceedMaximumSupply(_amount)
    {
        require(msg.sender != address(0), "cannot mint to the zero address");
        increaseTotalContentCreatorMinted(_amount);
        _mint(msg.sender, _amount);
        totalMinted += _amount;
    }

	/**
     * @dev	burn amount of tokens from the message sender

	 	Requirements:
		- the caller must have the `BURN_ROLE`.
     */
    function burn(uint256 _amount) public hasBurnRole {
		
        _burn(msg.sender, _amount);
        totalBurn += _amount;
        
    }

	function _beforeTokenTransfer(address from,address  to,uint256 amount) 
	internal view override {
	   // if some user transfer his tokens to this contract will loss the funds so we prevent
	   require( to != address(this) );
	}
    
}
