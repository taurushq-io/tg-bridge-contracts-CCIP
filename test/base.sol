// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./HelperContract.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "openzeppelin-contracts/mocks/token/ERC20Mock.sol";
import {Client} from "ccip/libraries/Client.sol";
contract baseTest is HelperContract {
    ERC20Mock private erc20;
    address private ROUTER = address(0x1);
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
    /*********** Get Router ***********/
    function testCanGetRouter() public view{
        address router = CCIPSENDER_CONTRACT.getRouter();
        assertEq(router,  ROUTER); 
    }
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

    function testCannotChangeStatusWithInvalidFeeId() public{
        // Act
        vm.prank(CCIPSENDER_ADMIN);
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderPayment_InvalidId.selector));
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(10, true);
    }
    /*********** CCIPSender withdraw***********/

    /*** ERC 20 tokens */
    function testAdminCanDepositAndWithdraw() public{
        uint256 value = 1000;
        // Arrange 
        erc20.mint(CCIPSENDER_ADMIN, value);
        // Act
        //vm.prank(CCIPSENDER_ADMIN);
        //CCIPSENDER_CONTRACT.depositTokens(address(erc20), value);
        vm.prank(CCIPSENDER_ADMIN);
        erc20.transfer(address(CCIPSENDER_CONTRACT), 1000);

        // assert
        assertEq(erc20.balanceOf(address(CCIPSENDER_CONTRACT)), value); 

        // Act
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawTokens(RECEIVER_ADDRESS, address(erc20), value);
        
        // Assert
        assertEq(erc20.balanceOf(RECEIVER_ADDRESS), value); 
    }
    function testAdminCannotWithdrawToTheZeroAddress() public{
        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_ContractBalance_Address_Zero_Not_Allowed.selector));
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawTokens(ZERO_ADDRESS, address(erc20), 1000);
    }

    function testAdminCannotWithdrawWithTokenContractAddressToZero() public{
        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_ContractBalance_Address_Zero_Not_Allowed.selector));
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawTokens(address(erc20),ZERO_ADDRESS, 1000);
    }

    function testAdminCannotWithdrawAllIfContractBalanceIsZero() public{
        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_ContractBalance_NothingToWithdraw.selector));
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.withdrawTokens(RECEIVER_ADDRESS, address(erc20), 0);
    }

    /****Build token amounts */
    function testCanBuildTokenAmounts() public view{
        // Arrange
        uint256 value = 1000;
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](1);
        _tokens[0] = address(erc20);
        _amounts[0] = value;
        
        // Act
        Client.EVMTokenAmount[] memory tokenAmounts = CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
        
        // Assert
        assertEq(tokenAmounts.length, 1);
        assertEq(tokenAmounts[0].token, address(erc20));
        assertEq(value, tokenAmounts[0].amount);
    }

    function testCannotBuildTokenAmountsIfLengthMismatch() public{
        // Arrange
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](0);
        _tokens[0] = address(erc20);

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderBuild_LengthMismatch.selector));
        CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
    }

    function testCannotBuildTokenAmountsIfTokenWithZeroAddress() public{
        // Arrange
        uint256 value = 1000;
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](1);
        _tokens[0] = ZERO_ADDRESS;
        _amounts[0] = value;

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderBuild_Address_Zero_Not_Allowed.selector));
        CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
    }

    function testCannotBuildTokenAmountsIfTokensIsEmpty() public{
        // Arrange
        uint256 value = 1000;
        address[] memory _tokens = new address[](0);
        uint256[] memory _amounts = new uint256[](1);
        _amounts[0] = value;

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderBuild_TokensIsEmpty.selector));
        CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
    }

}