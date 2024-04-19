// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./HelperContract.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {Client} from "ccip/libraries/Client.sol";
contract baseTest is HelperContract {
     // Arrange
    function setUp() public {
        // Deploy CCIP Sender
        CCIPSENDER_CONTRACT = new CCIPSender(
            CCIPSENDER_ADMIN,
            address(0x1),
            ZERO_ADDRESS
        );
    }
    /*********** CCIPAllowlistedChain ***********/
    function testCannotAttakerSetAvalancheBlockchainAsSourceAndSource() public{
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER,  BRIDGE_ALLOWLISTED_CHAIN_MANAGER_ROLE));  
        vm.prank(ATTACKER);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, true, true);
    }

    function testCannotAttakerUnsetAvalancheBlockchainAsSourceAndDestination() public{
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER,  BRIDGE_ALLOWLISTED_CHAIN_MANAGER_ROLE));  
        vm.prank(ATTACKER);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, false, false);
    }


    /*********** CCIPSender Payment ***********/
    function testCannotAttackerSetGasLimit() public{
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER,  BRIDGE_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        CCIPSENDER_CONTRACT.setGasLimit(1000);
    }

    function testCannotAttackerSetFeePaymentMethod() public{
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER,  BRIDGE_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        CCIPSENDER_CONTRACT.setFeePaymentMethod(AVALANCHE_USDC , "USDC");
    }

    function testCannotAdminCanDeactivateFeePaymentMethod() public{
        // Arrange
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setFeePaymentMethod(AVALANCHE_USDC , "USDC");
        
        // Act
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER,  BRIDGE_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(1 , false);
    }

    /*********** CCIPSender withdraw***********/
    function testCannotAttackerWithdrawNativeToken() public{
        // Arrange 
        vm.deal(CCIPSENDER_ADMIN, 1 ether);
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.depositNativeTokens{value: 1 ether}();

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, DEFAULT_ADMIN_ROLE));  
        vm.prank(ATTACKER);
        CCIPSENDER_CONTRACT.withdrawNativeTokens(RECEIVER_ADDRESS, 1 ether);
    }
}