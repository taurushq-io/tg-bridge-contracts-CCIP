// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "openzeppelin-contracts/mocks/token/ERC20Mock.sol";
import {Client} from "ccip/libraries/Client.sol";
contract baseTest is HelperContract {
    ERC20Mock private erc20;
    address private ROUTER = address(0x1);
    uint256  NATIVE_TOKEN_SELECTION = 0;
     // Arrange
    function setUp() public {
        // Deploy CCIP Sender
        CCIPSENDER_CONTRACT = new CCIPSender(
            CCIPSENDER_ADMIN,
            ROUTER,
            ZERO_ADDRESS
        );
        erc20 = new ERC20Mock();
    }
 

    /*********** CCIPSender Payment ***********/

    function testCanAdminSetTokenNativeAsFee() public{
        // Act
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(NATIVE_TOKEN_SELECTION , true);
        // Assert
        uint256 id;
        string memory label;
        bool isActivate;
        IERC20 tokenAddress;
        // Assert
        (id, label, isActivate, tokenAddress) = CCIPSENDER_CONTRACT.paymentTokens(NATIVE_TOKEN_SELECTION );
        assertEq(isActivate, true); 
    }

    /*********** CCIPSender withdraw***********/
    function testAdminCanDepositAndWithdrawNativeTokens() public{
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

    function testAdminCannotWithdrawNativeTokensToTheZeroAddress() public{
        // Arrange 
        vm.deal(CCIPSENDER_ADMIN, 1 ether);
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.depositNativeTokens{value: 1 ether}();

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_ContractBalance_Address_Zero_Not_Allowed.selector));
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawNativeTokens(ZERO_ADDRESS, 1 ether);
    }

    function testAdminCannotWithdrawNativeTokensAllIfContractBalanceIsZero() public{
        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_ContractBalance_NothingToWithdraw.selector));
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawNativeTokens(RECEIVER_ADDRESS, 0 ether);
    }




    /****Build token amounts */


    function testCanBuildCCIPTransferMessageForOneTokenWithNativeTokens() public{
        // Arrange
        uint256 value = 1000;
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](1);
        _tokens[0] = address(erc20);
        _amounts[0] = value;
        
        Client.EVMTokenAmount[] memory tokenAmounts = CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(NATIVE_TOKEN_SELECTION , true);
        
        // Act
        Client.EVM2AnyMessage memory message = CCIPSENDER_CONTRACT.buildCCIPTransferMessage(RECEIVER_ADDRESS, tokenAmounts, NATIVE_TOKEN_SELECTION);

        // Assert
        assertEq(abi.decode(message.receiver, (address)), RECEIVER_ADDRESS);
        assertEq(message.data, abi.encode(""));
        assertEq(tokenAmounts[0].token, address(erc20));
        assertEq(value, tokenAmounts[0].amount);
    }

    function testCannotBuildCCIPTransferMessageForOneTokenIfInvalidFeeWithNativeTokens() public{
        // Arrange
        uint256 value = 1000;
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](1);
        _tokens[0] = address(erc20);
        _amounts[0] = value;
        
        Client.EVMTokenAmount[] memory tokenAmounts = CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
        
        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderBuild_InvalidFeeId.selector));
        CCIPSENDER_CONTRACT.buildCCIPTransferMessage(RECEIVER_ADDRESS, tokenAmounts, NATIVE_TOKEN_SELECTION );
    }
}