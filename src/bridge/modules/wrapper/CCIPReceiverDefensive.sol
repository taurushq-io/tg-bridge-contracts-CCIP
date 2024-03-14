// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Client} from "ccip/libraries/Client.sol";
import {CCIPReceiverInternal} from "../internal/CCIPReceiverInternal.sol";
import "../security/AuthorizationModule.sol";
import {SafeERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {EnumerableMap} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableMap.sol";
import "../libraries/CCIPErrors.sol";
/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/// @title - A simple messenger contract for transferring/receiving tokens and data across chains.
/// @dev - This example shows how to recover tokens in case of revert
abstract contract CCIPReceiverDefensive is CCIPReceiverInternal, AuthorizationModule {

    using EnumerableMap for EnumerableMap.Bytes32ToUintMap;
    using SafeERC20 for IERC20;


    // Example error code, could have many different error codes.
    enum ErrorCode {
        // RESOLVED is first so that the default value is resolved.
        RESOLVED,
        // Could have any number of error codes here.
        BASIC
    }


    event MessageFailed(bytes32 indexed messageId, bytes reason);
    event MessageRecovered(bytes32 indexed messageId);

    bytes32 internal s_lastReceivedMessageId; // Store the last received messageId.
    address internal s_lastReceivedTokenAddress; // Store the last received token address.
    uint256 internal s_lastReceivedTokenAmount; // Store the last received amount.
    string internal s_lastReceivedText; // Store the last received text.


    // The message contents of failed messages are stored here.
    mapping(bytes32 messageId => Client.Any2EVMMessage contents)
        public s_messageContents;

    // Contains failed messages and their state.
    EnumerableMap.Bytes32ToUintMap internal s_failedMessages;

    // This is used to simulate a revert in the processMessage function.
    bool internal s_simRevert = false;



    /// @dev Modifier to allow only the contract itself to execute a function.
    /// Throws an exception if called by any account other than the contract itself.
    modifier onlySelf() {
        if (msg.sender != address(this)) {
            revert CCIPErrors.OnlySelf();
        }
        _;
    }


    /**
     * @notice Returns the details of the last CCIP received message.
     * @dev This function retrieves the ID, text, token address, and token amount of the last received CCIP message.
     * @return messageId The ID of the last received CCIP message.
     * @return text The text of the last received CCIP message.
     * @return tokenAddress The address of the token in the last CCIP received message.
     * @return tokenAmount The amount of the token in the last CCIP received message.
     */
    function getLastReceivedMessageDetails()
        public
        view
        returns (
            bytes32 messageId,
            string memory text,
            address tokenAddress,
            uint256 tokenAmount
        )
    {
        return (
            s_lastReceivedMessageId,
            s_lastReceivedText,
            s_lastReceivedTokenAddress,
            s_lastReceivedTokenAmount
        );
    }

    /**
     * @notice Retrieves the IDs of failed messages from the `s_failedMessages` map.
     * @dev Iterates over the `s_failedMessages` map, collecting all keys.
     * @return ids An array of bytes32 containing the IDs of failed messages from the `s_failedMessages` map.
     */
    function getFailedMessagesIds()
        external
        view
        returns (bytes32[] memory ids)
    {
        uint256 length = s_failedMessages.length();
        bytes32[] memory allKeys = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            (bytes32 key, ) = s_failedMessages.at(i);
            allKeys[i] = key;
        }
        return allKeys;
    }


    /// @notice Allows the owner to retry a failed message in order to unblock the associated tokens.
    /// @param messageId The unique identifier of the failed message.
    /// @param tokenReceiver The address to which the tokens will be sent.
    /// @dev This function is only callable by the contract owner. It changes the status of the message
    /// from 'failed' to 'resolved' to prevent reentry and multiple retries of the same message.
    function retryFailedMessage(
        bytes32 messageId,
        address tokenReceiver
    ) external onlyRole(BRIDGE_MESSAGE_MANAGER) {
        // Check if the message has failed; if not, revert the transaction.
        if (s_failedMessages.get(messageId) != uint256(ErrorCode.BASIC)){
            revert CCIPErrors.CCIP_RECEIVER_DEFENSIVE_MessageNotFailed(messageId);
        }
        // Set the error code to RESOLVED to disallow reentry and multiple retries of the same failed message.
        s_failedMessages.set(messageId, uint256(ErrorCode.RESOLVED));

        // Retrieve the content of the failed message.
        Client.Any2EVMMessage memory message = s_messageContents[messageId];

        // This example expects one token to have been sent, but you can handle multiple tokens.
        // Transfer the associated tokens to the specified receiver as an escape hatch.
        IERC20(message.destTokenAmounts[0].token).safeTransfer(
            tokenReceiver,
            message.destTokenAmounts[0].amount
        );

        // Emit an event indicating that the message has been recovered.
        emit MessageRecovered(messageId);
    }


    /// @notice Allows the owner to toggle simulation of reversion for testing purposes.
    /// @param simRevert If `true`, simulates a revert condition; if `false`, disables the simulation.
    /// @dev This function is only callable by the contract owner.
    function setSimRevert(bool simRevert) public onlyRole(BRIDGE_MESSAGE_MANAGER) {
        s_simRevert = simRevert;
    }


    function supportsInterface(bytes4 interfaceId) public virtual pure override( AuthorizationModule, CCIPReceiverInternal) 
    returns (bool){
        return ( CCIPReceiverInternal.supportsInterface(interfaceId) || AuthorizationModule.supportsInterface(interfaceId));
    
    }
}
