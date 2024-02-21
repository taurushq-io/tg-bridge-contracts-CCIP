// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./wrapper/CCIPAllowlistedChain.sol";
import "./wrapper/CCIPSenderInternal.sol";
import {IRouterClient} from "ccip/interfaces/IRouterClient.sol";
import {Client} from "ccip/libraries/Client.sol";
import "../libraries/CCIPErrors.sol";
import "./internal/CCIPRouterManage.sol"; 
abstract contract CCIPBaseSender is CCIPAllowlistedChain, CCIPSenderInternal, CCIPRouterManage {
     // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance to cover the fees.
    bytes32 public constant CCIP_USER_ROLE = keccak256("CCIP_USER_ROLE");
    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        string text, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    event TokensTransferred(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        address token, // The token address that was transferred.
        uint256 tokenAmount, // The token amount that was transferred.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.
    );

    /// @notice Sends data to receiver on the destination chain.
    /// @notice Pay for fees in LINK.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _receiver The address of the recipient on the destination blockchain.
    /// @param _text The text to be sent.
    /// @return messageId The ID of the CCIP message that was sent.
    function sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        string memory _text
    )
        internal
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _text,
            address(s_linkToken)
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this))){
            revert  CCIPErrors.CCIP_NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }
            

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(router), fees);

        // Send the CCIP message through the router and store the returned CCIP message ID
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _text,
            address(s_linkToken),
            fees
        );

        // Return the CCIP message ID
        return messageId;
    }

     /*
    * @notice transfer tokens
    * @param _receiver address on the destination blockchain
    * @param _token token contract on the source chain
    * @param _amount token amount to transfer
    */
    function transferTokens(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount
    ) 
        external onlyRole(CCIP_USER_ROLE)
        returns (bytes32 messageId) 
    {
        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;
        
        // Build the CCIP Message
        Client.EVM2AnyMessage memory message = _buildCCIPTransferMessage(_receiver, tokenAmounts);
        
        // CCIP Fees Management
        uint256 fees = router.getFee(_destinationChainSelector, message);

        if (fees > s_linkToken.balanceOf(address(this))){
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }


        s_linkToken.approve(address(router), fees);
        
        // Approve Router to spend CCIP-BnM tokens we send
        IERC20(_token).approve(address(router), _amount);
        
        // Send CCIP Message
        messageId = router.ccipSend(_destinationChainSelector, message); 
        
        emit TokensTransferred(
            messageId,
            _destinationChainSelector,
            _receiver,
            _token,
            _amount,
            address(s_linkToken),
            fees
        );   
    }
}