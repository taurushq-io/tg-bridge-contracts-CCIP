// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../../../modules/AuthorizationModule.sol";
import "../../libraries/CCIPErrors.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/// @title - A simple messenger contract for sending/receving string data across chains.
abstract contract CCIPAllowlistedChain is AuthorizationModule {
     bytes32 public constant BRIDGE_ALLOWLISTED_CHAIN_MANAGER = keccak256("BRIDGE_USER_ROLE");
   
    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;


    /// @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
    /// @param _destinationChainSelector The selector of the destination chain.
    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!allowlistedDestinationChains[_destinationChainSelector])
            revert CCIPErrors.CCIP_CCIPAllowListedChain_DestinationChainNotAllowlisted(_destinationChainSelector);
        _;
    }

    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the destination chain.
    /// @param _sender The address of the sender.
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (!allowlistedSourceChains[_sourceChainSelector]){
            revert CCIPErrors.CCIP_CCIPAllowListedChain_SourceChainNotAllowlisted(_sourceChainSelector);
        }
            
            //To improve
        //if (!allowlistedSenders[_sender]) revert CCIPErrors.CCIP_CCIPAllowListedChain_SenderNotAllowlisted(_sender);
        _;
    }

    /// @dev Updates the allowlist status of a destination chain for transactions.
    function allowlistDestinationChain(
        uint64 _destinationChainSelector,
        bool allowed
    ) external onlyRole(BRIDGE_ALLOWLISTED_CHAIN_MANAGER) {
        allowlistedDestinationChains[_destinationChainSelector] = allowed;
    }

    /// @dev Updates the allowlist status of a source chain for transactions.
    function allowlistSourceChain(
        uint64 _sourceChainSelector,
        bool allowed
    ) external onlyRole(BRIDGE_ALLOWLISTED_CHAIN_MANAGER) {
        allowlistedSourceChains[_sourceChainSelector] = allowed;
    }

    /*function supportsInterface(bytes4 interfaceId) public virtual pure override( AuthorizationModule) 
    returns (bool){
        return ( AuthorizationModule.supportsInterface(interfaceId));
    
    }*/

}