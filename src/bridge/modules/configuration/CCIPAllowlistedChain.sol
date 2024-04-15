// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../security/AuthorizationModule.sol";
import "../libraries/CCIPErrors.sol";

/// @title - Define chain allowed
abstract contract CCIPAllowlistedChain is AuthorizationModule {
    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    /// @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
    /// @param _destinationChainSelector The selector of the destination chain.
    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!allowlistedDestinationChains[_destinationChainSelector])
            revert CCIPErrors.CCIP_AllowListedChain_DestinationChainNotAllowlisted(_destinationChainSelector);
        _;
    }
    
    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the destination chain.
    modifier onlyAllowlisted(uint64 _sourceChainSelector) {
        if (!allowlistedSourceChains[_sourceChainSelector]){
            revert CCIPErrors.CCIP_AllowListedChain_SourceChainNotAllowlisted(_sourceChainSelector);
        }
        _;
    }

    /**
    * @notice Updates the allowlist status of chain for transactions (source and destination).
    * @param _chainSelector selector from CCIP
    * @param allowedSourceChain boolean to add(true) or remove(false) the selected blockchain
    * @param allowedDestinationChain boolean to add(true) or remove(false) the selected blockchain
    */ 
    function setAllowlistChain(
        uint64 _chainSelector,
        bool allowedSourceChain,
        bool allowedDestinationChain
    ) external onlyRole(BRIDGE_ALLOWLISTED_CHAIN_MANAGER_ROLE) {
        if(allowlistedSourceChains[_chainSelector] !=  allowedSourceChain){
            allowlistedSourceChains[_chainSelector] = allowedSourceChain;
        }
        if( allowlistedDestinationChains[_chainSelector] !=  allowedDestinationChain){
            allowlistedDestinationChains[_chainSelector] = allowedDestinationChain;
        }
    }
}