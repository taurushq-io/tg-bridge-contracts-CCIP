// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface BridgeVaultInterface {
    error BridgeVault_tokenNoBridgeable();
    error BridgeVault_AddressZeroNotAllowed();
    // by the token holder
    event Deposit(address indexed receiverBlockchainDestination, address indexed sourceContract, address indexed destinationContract, uint256 value);
    event Withdraw(address indexed sender, address indexed receiverBlockchainSource, address indexed sourceContract, uint256 value);
    // By the validator
    event Mint(address indexed receiver, address indexed sourceContract, uint256 value);
    event Unlock(address indexed sender, address indexed sourceContract, address indexed destinationContract, uint256 value);
    //event Burn(address indexed receiver, address indexed sourceContract, uint256 value);
 
    event NewWrapperContract(address indexed sourceContract, address indexed wrapperContract);
}