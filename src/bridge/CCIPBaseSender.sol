// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./modules/wrapper/CCIPSenderBuild.sol";
import {Client} from "ccip/libraries/Client.sol";
import {SafeERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import "./modules/configuration/CCIPRouterManage.sol"; 
import "./modules/configuration/CCIPAllowlistedChain.sol";
abstract contract CCIPBaseSender is CCIPAllowlistedChain, CCIPSenderBuild, CCIPRouterManage {
    using SafeERC20 for IERC20;
    // Event emitted when tokens are transfered
    event TokenSingleTransferred(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        address token, // The token address that was transferred.
        uint256 tokenAmount, // The token amount that was transferred.
        uint256 _paymentMethodId, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.
    );

    event TokensBatchTransferred(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        address[] tokens, // The token addresses that was transferred.
        uint256[] tokenAmounts, // The token amountes that were transferred.
        uint256 _paymentMethodId, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.
    );

    /*
    * @notice transfer `_amount` of the same token.
    * @param _receiver address on the destination blockchain
    * @param _token token contract on the source chain
    * @param _amount token amount to transfer
    * @_paymentMethodId the id to specifcy the payment method
    * @return message id
    */
    function transferTokens(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount,
        uint256 _paymentMethodId
    ) 
        external 
        onlyRole(BRIDGE_USER_ROLE)
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        returns (bytes32 messageId) 
    {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;
        uint256 fees;
        
        (fees,  messageId) = _buildEndSend(_destinationChainSelector, _receiver, _paymentMethodId, tokenAmounts);
        
        emit TokenSingleTransferred(
            messageId,
            _destinationChainSelector,
            _receiver,
            _token,
            _amount,
            _paymentMethodId,
            fees
        );   
    }

    /**
    * @notice transfer tokens
    * @param _receiver address on the destination blockchain
    * @param _tokens token contract on the source chain
    * @param _amounts token amount to transfer
    */
    function transferTokensBatch(
        uint64 _destinationChainSelector,
        address _receiver,
        address[] memory _tokens,
        uint256[] memory _amounts,
        uint256 _paymentMethodId
    ) 
        external 
        onlyRole(BRIDGE_USER_ROLE) 
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        returns (bytes32 messageId) 
    {
        Client.EVMTokenAmount[]
            memory tokenAmounts = buildTokenAmounts(_tokens, _amounts);
        uint256 fees;
        (fees,  messageId) = _buildEndSend(_destinationChainSelector, _receiver, _paymentMethodId, tokenAmounts);
       
        emit TokensBatchTransferred(
            messageId,
            _destinationChainSelector,
            _receiver,
            _tokens,
            _amounts,
            _paymentMethodId,
            fees
        );   
    }

    /**
    * @notice buildEndSend
    * @param _destinationChainSelector Id selector for the destination blockchain
    * @param _receiver address on the destination blockchain
    * @param _paymentMethodId id to select the payment
    * @param tokenAmounts array for each token
    */
    function _buildEndSend(uint64 _destinationChainSelector, address _receiver,  uint256 _paymentMethodId,  Client.EVMTokenAmount[] memory tokenAmounts) internal returns(uint256 fees, bytes32 messageId){
        // Build the CCIP Message
        Client.EVM2AnyMessage memory message = CCIPSenderBuild._buildCCIPTransferMessage(_receiver, tokenAmounts, _paymentMethodId );
        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(CCIPRouterManage.getRouter());
        // CCIP Fees Management
        fees = CCIPSenderPayment._computeAndApproveFee(_destinationChainSelector, message, router, _paymentMethodId);
        for(uint256 i = 0; i < tokenAmounts.length; ++i){
        // transfer tokens to the contract
        IERC20(tokenAmounts[i].token).safeTransferFrom(_msgSender(), address(this), tokenAmounts[i].amount);
        /*if(!result){
                revert CCIPErrors.CCIP_BaseSender_FailSafeTransferFrom();
        }*/
        // approve the Router to spend tokens on contract's behalf. It will spend the amount of the given token
        bool result = IERC20(tokenAmounts[i].token).approve(address(router), tokenAmounts[i].amount);
        if(!result){
            revert CCIPErrors.CCIP_BaseSender_FailApproval();
        }
        }
        // Send CCIP Message
        messageId = router.ccipSend(_destinationChainSelector, message); 
    }

    
}