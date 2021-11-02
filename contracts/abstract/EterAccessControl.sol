// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ExtendedAccessControl.sol";

/**
 * @title EterAccessControl
 * @dev This contract defines all roles and modifiers for Eter token authorization
 */
abstract contract EterAccessControl is ExtendedAccessControl {
    
	constructor(uint8 requiredVotes) 
	ExtendedAccessControl(requiredVotes){

	}
	
	bytes32 private constant ECOSYSTEM_MINTER_ROLE =
        keccak256("ECOSYSTEM_MINTER_ROLE");
    bytes32 private constant LIQUIDITY_MINTER_ROLE =
        keccak256("LIQUIDITY_MINTER_ROLE");
    bytes32 private constant MOD_MINTER_ROLE = keccak256("MOD_MINTER_ROLE");
    bytes32 private constant STAKING_MINTER_ROLE =
        keccak256("STAKING_MINTER_ROLE");
    bytes32 private constant EVENTS_MINTER_ROLE =
        keccak256("EVENTS_MINTER_ROLE");
    bytes32 private constant CONTENT_CREATORS_MINTER_ROLE =
        keccak256("CONTENT_CREATORS_MINTER_ROLE");
    bytes32 private constant BURN_ROLE = 
		keccak256("BURN_ROLE");

   



    modifier hasBurnRole() {
        require(
            hasRole(BURN_ROLE, msg.sender),
            "Only the burn role can perform this action"
        );
        _;
    }

    modifier hasEcosystemMinterRole() {
        require(
            hasRole(ECOSYSTEM_MINTER_ROLE, msg.sender),
            "Caller is not ecosystem minter"
        );
        _;
    }
    modifier hasLiquidityMinterRole() {
        require(
            hasRole(LIQUIDITY_MINTER_ROLE, msg.sender),
            "Caller is not liquidity minter"
        );
        _;
    }
    modifier hasModeratorRole() {
        require(
            hasRole(MOD_MINTER_ROLE, msg.sender),
            "Caller is not moderator"
        );
        _;
    }
    modifier hasStakingRole() {
        require(
            hasRole(STAKING_MINTER_ROLE, msg.sender),
            "Caller is not staking"
        );
        _;
    }
    modifier hasEventMinterRole() {
        require(hasRole(EVENTS_MINTER_ROLE, msg.sender), "Caller is not event");
        _;
    }
    modifier hasContentCreatorRole() {
        require(
            hasRole(CONTENT_CREATORS_MINTER_ROLE, msg.sender),
            "Caller is not content creator"
        );
        _;
    }

	/**
		@dev return all available roles
	**/
    function getRoles()
        public
        pure
        returns (
            bytes32 EcosystemMinter,
            bytes32 LiquidityMinter,
            bytes32 ModMinter,
            bytes32 StakingMinter,
            bytes32 EventsMinter,
            bytes32 ContentCreatorsMinter,
            bytes32 BurnRole
        )
    {
        EcosystemMinter = ECOSYSTEM_MINTER_ROLE;
        LiquidityMinter = LIQUIDITY_MINTER_ROLE;
        ModMinter = MOD_MINTER_ROLE;
        StakingMinter = STAKING_MINTER_ROLE;
        EventsMinter = EVENTS_MINTER_ROLE;
        ContentCreatorsMinter = CONTENT_CREATORS_MINTER_ROLE;
        BurnRole = BURN_ROLE;
    }

 
}
