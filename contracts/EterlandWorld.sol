// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Eterland Nft World
 * @dev Contract that follows ERC721 standard to hold nfts from eterland world
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ExtendedAccessControl.sol";

contract EterlandWorld is ERC721, ExtendedAccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
	/*
		Store ids of nfts that are disabled
	 */
    mapping(uint256 => bool) private _isDisabled;
	
	/**
 	* @dev Event is emitted when new nft is minted
 	*/
    event New(address owner, uint256 id);
	/**
 	* @dev Event is emitted when a nft change his status ( disabled or enabled)
 	*/
	event StatusChanged(address owner, uint256 id, bool status);

	/**
 	* @dev  allow to the owner of this role mint new nfts
 	*/
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	/**
 	* @dev allow to the owner of this role to disable nfts and pause it's functionalities 
 	*/
    bytes32 public constant NFT_ADMINISTRATOR_ROLE = keccak256("NFT_ADMINISTRATOR_ROLE");

    modifier hasMinterRole() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Minter role is required");
        _;
    }
    modifier hasNftAdministratorRole() {
        require(hasRole(NFT_ADMINISTRATOR_ROLE, _msgSender()), "Burner role is required");
        _;
    }

	/**
 	* @dev set admin role to all member of team and required votes to update a role to 4
 	*/
    constructor(address ceo, address coo, address cfo, address inv1, address inv2) 
	ERC721("Eterland", "ETL") 
	ExtendedAccessControl(4) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, ceo);
        _setupRole(DEFAULT_ADMIN_ROLE, coo);
		_setupRole(DEFAULT_ADMIN_ROLE, cfo);
		_setupRole(DEFAULT_ADMIN_ROLE, inv1);
		_setupRole(DEFAULT_ADMIN_ROLE, inv2);
    }


	/**
 	* @dev mint new nft
 	*/
    function mint(address player) public 
	hasMinterRole
	returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        _safeMint(player, newItemId);
		
		emit New(player,newItemId);
        
		return newItemId;
    }

   	
   function burn(uint256 id) public{
	    require(_isApprovedOrOwner(_msgSender(), id), 
		"ERC721: transfer caller is not owner nor approved");
	   _burn(id);
   }

   function changeStatus(uint256 id,bool status) 
   hasNftAdministratorRole 
   public {

	   	require(_exists(id),"didn't exist");   
		_isDisabled[id] = status;
	   	address owner = ownerOf(id);

		emit StatusChanged(owner, id, status);
   }

	/**
 	* @dev this method allow to nft administrator to disable game functionalities for nft 
	* is here for security purposes 
	* i.e if some user explode a serious bug in the game his nft will be disabled 
 	*/
   function isDisabled(uint256 id) external view returns(bool){
	   	require(_exists(id),"didn't exist");   

		return _isDisabled[id];
   }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


	  function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721) {
        require(
          	_isDisabled[tokenId]==false,
            "This nft is disabled"
        );
    }
}