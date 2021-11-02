// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Presale
 * @dev This contract handles a presale with 6 team members with required approvals of four to withdraw funds. 
 */

abstract contract Presale {

    address private CEO;
    address private CTO;
    address private COO;
	address private CFO;
	address private INV1;
	address private INV2;

	/**
     * @dev Used to store payment approvals from team members
     */
    struct paymentApproval {
        bool ceo;
        bool cto;
        bool coo;
		bool cfo;
		bool inv1;
		bool inv2;
    }

    uint256 public PRESALE_END_TIMESTAMP;
    uint256 public PRESALE_START_TIMESTAMP;


	/**
     * @dev Store payment approvals to specific wallet address 
     */
    mapping(address => paymentApproval) private _paymentApproval;


	/**
     * @dev Set team members and presale time 
     */
    constructor(
        uint256 presaleStart,
        uint256 presaleEnd,
        address ceo,
        address coo,
		address cfo,
		address inv1, 
		address inv2
    ) {
        PRESALE_END_TIMESTAMP = presaleEnd;
        PRESALE_START_TIMESTAMP = presaleStart;
        CTO = msg.sender;
        CEO = ceo;
        COO = coo;
		CFO = cfo;
		INV1 = inv1;
		INV2 = inv2;
    }

    modifier onlyTeamMember() {
        require(
            msg.sender == CEO ||
			msg.sender == CTO ||
			msg.sender == COO ||
			msg.sender == CFO || 
			msg.sender == INV1 || 
			msg.sender == INV2,
            "not enought permissions"
        );
        _;
    }

    modifier presaleInProgress() {

        uint256 currentTimeStamp = block.timestamp;

        require(
            currentTimeStamp < PRESALE_END_TIMESTAMP &&
                currentTimeStamp >= PRESALE_START_TIMESTAMP,
            "presale is not inprogress"
        );
        _;
    }


    function getCTO() external view returns (address) {
        return CTO;
    }

    function getCEO() external view returns (address) {
        return CEO;
    }

    function getCOO() external view returns (address) {
        return COO;
    }

	 function getCFO() external view returns (address) {
        return CFO;
    }

    function getINV1() external view returns (address) {
        return INV1;
    }

    function getINV2() external view returns (address) {
        return INV2;
    }

	/**
     * @dev Getter for presale end timestamp
     */
    function getEndTimestamp() external view returns (uint256) {
        return PRESALE_END_TIMESTAMP;
    }

	/**
     * @dev Getter for presale start timestamp
     */
    function getStartTimestamp() external view returns (uint256) {
        return PRESALE_START_TIMESTAMP;
    }


	/** 
		@dev Update votes count and release coins to the wallet with 4 votes
	*/
    function payContract(address destination) public onlyTeamMember {
		
		require(destination != address(0) && 
		destination != address(this),
		"Invalid wallet");

        _approvePayment(destination);
        uint8 approvalCount = _getPaymentApprovals(destination);

        if (approvalCount >= 4) {
            payable(destination).transfer(address(this).balance);
			_resetVotesCount(destination);
        }
    }

	/**
     * @dev set vote for the team member that is calling the contract
     */
    function _approvePayment(address destination) private {
        if (msg.sender == COO) {
            _paymentApproval[destination].coo = true;
        } else if (msg.sender == CEO) {
            _paymentApproval[destination].ceo = true;
        } else if (msg.sender == CTO) {
            _paymentApproval[destination].cto = true;
        }
		else if(msg.sender == CFO){
			_paymentApproval[destination].cfo = true;
		}
		else if(msg.sender == INV1){
			_paymentApproval[destination].inv1 = true;
		}
		else if(msg.sender == INV2){
			_paymentApproval[destination].inv2 = true;
		}
    }
	/**
     * @dev count votes from team members 
     */
    function _getPaymentApprovals(address destination)
        private
        view
        returns (uint8 aproveCount)
    {
        aproveCount = 0;
        if (_paymentApproval[destination].ceo == true) {
            aproveCount++;
        }
        if (_paymentApproval[destination].coo == true) {
            aproveCount++;
        }
        if (_paymentApproval[destination].cto == true) {
            aproveCount++;
        }
		if(_paymentApproval[destination].cfo == true){
			aproveCount ++;
		}
		if(_paymentApproval[destination].inv1 == true){
			aproveCount ++;
		}
		if(_paymentApproval[destination].inv2 == true){
			aproveCount ++;
		}
    }
	/**
     * @dev	reset votes count, this function is called after send a payment to reset the contract status
     */
	function _resetVotesCount(address destination) private{
		delete _paymentApproval[destination].ceo;
		delete _paymentApproval[destination].coo;
		delete _paymentApproval[destination].cto;
		delete _paymentApproval[destination].cfo;
		delete _paymentApproval[destination].inv1;
		delete _paymentApproval[destination].inv2;
	}
    
}
