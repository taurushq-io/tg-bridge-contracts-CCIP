// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./HelperContract.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {Client} from "ccip/libraries/Client.sol";
contract baseTest is HelperContract {
    struct FEE_PAYMENT_TOKEN {
        uint256 id;
        string label;
        bool isActivate;
        IERC20 tokenAddress;
    }
    uint64 AVALANCHE_SELECTOR = 6433500567565415381;
    IERC20 AVALANCHE_USDC = IERC20(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E);
     // Arrange
    function setUp() public {
        // Deploy CCIP Sender
        CCIPSENDER_CONTRACT = new CCIPSender(
            CCIPSENDER_ADMIN,
            address(0x1),
            ZERO_ADDRESS
        );
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}


    // Fallback function is called when msg.data is not empty
    // Test withdraw
    fallback() external payable {}

    /*********** CCIPAllowlistedChain ***********/
    function testAdminCanSetAvalancheBlockchainAsSourceAndSource() public{
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, true, true);
        resBool = CCIPSENDER_CONTRACT.allowlistedSourceChains(AVALANCHE_SELECTOR);
        assertEq(resBool, true); 
        resBool = CCIPSENDER_CONTRACT.allowlistedDestinationChains(AVALANCHE_SELECTOR);
        assertEq(resBool, true); 
    }

    function testAdminCanUnsetAvalancheBlockchainAsSourceAndDestination() public{
        // Arrange
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, true, true);
        resBool = CCIPSENDER_CONTRACT.allowlistedSourceChains(AVALANCHE_SELECTOR);
        assertEq(resBool, true); 
        resBool = CCIPSENDER_CONTRACT.allowlistedDestinationChains(AVALANCHE_SELECTOR);
        assertEq(resBool, true); 
    
        // Act
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, false, false);

        // Assert
        resBool = CCIPSENDER_CONTRACT.allowlistedSourceChains(AVALANCHE_SELECTOR);
        assertEq(resBool, false); 
        resBool = CCIPSENDER_CONTRACT.allowlistedDestinationChains(AVALANCHE_SELECTOR);
        assertEq(resBool, false); 
    }


    /*********** CCIPSender Payment ***********/
    function testAdminCanSetFeePaymentMethod() public{
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setFeePaymentMethod(AVALANCHE_USDC , "USDC");

        resBool = CCIPSENDER_CONTRACT.tokenPaymentConfigured(address(AVALANCHE_USDC));
        assertEq(resBool, true); 
    }

    function testAdminCanDeactivateFeePaymentMethod() public{
        // Arrange
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setFeePaymentMethod(AVALANCHE_USDC , "USDC");
        
        // Act
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(1 , false);
        uint256 id;
        string memory label;
        bool isActivate;
        IERC20 tokenAddress;
        // Assert
        (id, label, isActivate, tokenAddress) = CCIPSENDER_CONTRACT.paymentTokens(1);
        assertEq(isActivate, false); 
    }

    function testAdminCannotSetPaymentMethodTwice() public{
        // Arrange
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setFeePaymentMethod(AVALANCHE_USDC , "USDC");
        
        // Act + Assert
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderPayment_TokenAlreadySet.selector));
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setFeePaymentMethod(AVALANCHE_USDC , "USDC");
    }
    /*********** CCIPSender withdraw***********/
        function testAdminCanDepositAndWithdraw() public{
        // Arrange 
        vm.deal(CCIPSENDER_ADMIN, 1 ether);
        // Act
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.depositNativeTokens{value: 1 ether}();
        // Assert
        assertEq(CCIPSENDER_ADMIN.balance, 0 ether); 
        // Act
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawNativeTokens(RECEIVER_ADDRESS, 1 ether);
        
        // Assert
        assertEq(RECEIVER_ADDRESS.balance, 1 ether); 
    }
}