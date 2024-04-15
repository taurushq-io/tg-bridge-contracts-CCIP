//SPDX-License-Identifier: MPL-2.0
import "../src/deployment/CCIPSender.sol";
import "../src/bridge/modules/libraries/CCIPErrors.sol";
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

/**
* @title Constants used by the tests
*/
abstract contract HelperContract is Test{
    uint256 resUint256;
    bool resBool;
    CCIPSender CCIPSENDER_CONTRACT;
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
    address constant CCIPSENDER_ADMIN = address(9);
    // role string

    string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";

    constructor() {}
}
