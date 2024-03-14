//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "../src/DebtVault.sol";
import "../src/invariantStorage/DebtVaultInvariantStorage.sol";
import "RuleEngine/RuleEngine.sol";
import "RuleEngine/rules/validation/RuleWhitelist.sol";
import "OZ/token/ERC20/IERC20.sol";
import "OZ/token/ERC20/ERC20.sol";
/**
* @title Constants used by the tests
*/
abstract contract HelperContract is DebtVaultInvariantStorage {
    // EOA to perform tests
    address constant ZERO_ADDRESS = address(0);
    address constant DEFAULT_ADMIN_ADDRESS = address(1);
    // Operator
    address constant DEBT_VAULT_OPERATOR_ADDRESS = address(2);
    address constant DEBT_VAULT_DEPOSIT_OPERATOR_ADDRESS = address(3);
    address constant DEBT_VAULT_WITHDRAW_OPERATOR_ADDRESS = address(8);
    // Other
    address constant ATTACKER = address(4);
    address constant ADDRESS1 = address(5);
    address constant ADDRESS2 = address(6);
    address constant ADDRESS3 = address(7);
    address constant TOKEN_PAYMENT_ADMIN = address(8);
    address constant CMTAT_ADMIN = address(9);
    // role string
    string constant RULE_ENGINE_ROLE_HASH =
        "0x774b3c5f4a8b37a7da21d72b7f2429e4a6d49c4de0ac5f2b831a1a539d0f0fd2";
    string constant WHITELIST_ROLE_HASH =
        "0xdc72ed553f2544c34465af23b847953efeb813428162d767f9ba5f4013be6760";
    string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";
    
    // contract
    CMTAT_STANDALONE CMTAT_CONTRACT;

    //bytes32 public constant RULE_ENGINE_ROLE = keccak256("RULE_ENGINE_ROLE");

    uint8 constant NO_ERROR = 0;

    // Forwarder
    string ERC2771ForwarderDomain = 'ERC2771ForwarderDomain';


        // Contracts
    CMTAT_STANDALONE tokenPayment;
    DebtVault debtVault;
    // CMTAT value
    uint256 FLAG = 5;
    uint8 DECIMALS = 0;
    uint256 ADDRESS1_INITIAL_AMOUNT = 5000;
    uint256 CMTAT_ADMIN_INITIAL_AMOUNT = 5000;

    
    uint256 defaultSnapshotTime = block.timestamp + 50;
    uint256 defaultDepositAmount = 2000;
    constructor() {}
}
