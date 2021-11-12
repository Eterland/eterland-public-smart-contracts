// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
/**
 * @title ExtendedAccessControl
 * @dev This is a extension from openzeppelin AccessControl that allow to require determinated number of admin votes to assign or revoke roles
 */
abstract contract ExtendedAccessControl is AccessControl {

	/**
		@dev set required number of votes to assign or revoke role
	**/
	constructor(uint8 requiredVotes){
		_requiredVotes = requiredVotes;
	}

	uint8 private _requiredVotes; 

	/**
		@dev stores  approvals for specific address and role
	**/
	mapping(address => mapping(bytes32 => mapping(address => bool))) private _roleApprovalVotation;
	
	/**
		@dev stores address of administrators that voted to assign a role to a specific address
	**/
	mapping(address => mapping(bytes32 => address[])) private 
	_rolesApprovalVotes;
	
	/**
		@dev stores votes to revoke specific role for an addres
	**/
	mapping(address => mapping(bytes32 => mapping(address => bool))) private  _roleRevokeVotation;

	
	/**
		@dev stores address of administrators that voted to revoke a role to a specific address
	**/
	mapping(address => mapping(bytes32 => address[])) private 
	_rolesRevokeVotes;


	/**
		@dev update votation to revoke role and if the number of votes are greater than the requiredvotes revoke role 
	**/
    function revokeRole(bytes32 role, address account)
        public
        override
        onlyRole(getRoleAdmin(role))
    {
        _revokeRoleVote(account, role);

		if(_rolesRevokeVotes[account][role].length >= _requiredVotes){
			super.revokeRole(role,account);
			_restoreVotation(account,role);
		}

    }

	

	/**
		@dev update votation to assign a role to an address and if the votes are greater than required votes assign role
	**/
    function grantRole(bytes32 role, address account)
        public
        override
        onlyRole(getRoleAdmin(role))
    {
        _approveRoleVote(account, role);

		if(_rolesApprovalVotes[account][role].length >= _requiredVotes){
			super.grantRole(role,account);
			_restoreVotation(account,role);
		}
    }

	/**
		@dev update votation to assign a role
	**/
    function _approveRoleVote(address _address, bytes32 _role)
        private
        returns (bool)
    {
        require(_address != address(0));
		require(!_roleApprovalVotation[_address][_role][_msgSender()],
		"You can vote only one time");

		_roleApprovalVotation[_address][_role][_msgSender()] = true;
		_rolesApprovalVotes[_address][_role].push(_msgSender());

        return true;
    }
	/**
		@dev update votation to revoke a role
	**/
    function _revokeRoleVote(address _address, bytes32 _role)
        private
        returns (bool)
    {
        require(_address != address(0));
       require(!_roleRevokeVotation[_address][_role][_msgSender()],
		"You can vote only one time");

		
		_roleRevokeVotation[_address][_role][_msgSender()] = true;
		_rolesRevokeVotes[_address][_role].push(_msgSender());

        return true;
    }

	/**
		@dev reset votation for specific address and role
	**/
	function _restoreVotation(address _address,bytes32 _role) private{
	
		for(uint i = 0 ; i< _rolesRevokeVotes[_address][_role].length ;i++)
		{
			delete _roleRevokeVotation[_address][_role][_rolesRevokeVotes[_address][_role][i]];
		}
		delete _rolesRevokeVotes[_address][_role];


		for(uint i = 0 ; i< _rolesApprovalVotes[_address][_role].length ;i++)
		{
			delete _roleApprovalVotation[_address][_role][_rolesApprovalVotes[_address][_role][i]];
		}
		delete _rolesApprovalVotes[_address][_role];
	}
}
