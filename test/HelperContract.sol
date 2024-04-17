//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "src/deployment/CCIPSender.sol";
import "src/bridge/modules/libraries/CCIPErrors.sol";
import "src/bridge/modules/security/AuthorizationModule.sol";
import "forge-std/Test.sol";

/**
* @title Constants used by the tests
*/
abstract contract HelperContract is Test, AuthorizationModule{
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
    address constant CCIPSENDER_ADMIN = address(0x9);
    address constant RECEIVER_ADDRESS = address(0xA);

    uint64 AVALANCHE_SELECTOR = 6433500567565415381;
    IERC20 AVALANCHE_USDC = IERC20(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E);
    // role string

    string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";


    // Import
    struct FEE_PAYMENT_TOKEN {
        uint256 id;
        string label;
        bool isActivate;
        IERC20 tokenAddress;
    }
    constructor() {}
}
