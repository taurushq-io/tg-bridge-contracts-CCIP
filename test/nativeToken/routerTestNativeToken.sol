// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "../utils/router.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "openzeppelin-contracts/mocks/token/ERC20Mock.sol";
import {Client} from "ccip/libraries/Client.sol";
contract RouterTest is HelperContract {
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    ERC20Mock private erc20;
    MockCCIPRouter private ROUTER;
    uint256 feePaymentId = 0;
     // Arrange
    function setUp() public {
        erc20 = new ERC20Mock();
        address[] memory supportedTokens = new address[](1);
        supportedTokens[0] = address(erc20);
        ROUTER = new MockCCIPRouter( supportedTokens );

        // Deploy CCIP Sender
        CCIPSENDER_CONTRACT = new CCIPSender(
            CCIPSENDER_ADMIN,
            address(ROUTER),
            ZERO_ADDRESS
        );
    }
    /*********** Get Router ***********/
    function testCanGetRouter() public  view {
        address router = CCIPSENDER_CONTRACT.getRouter();
        assertEq(router,  address(ROUTER)); 
    }

    function testCanGetSupportedTokens() public view {
        // From router mock
        uint64 chainSelector = 0;
        address[] memory tokens = CCIPSENDER_CONTRACT.getSupportedTokens(chainSelector);
        assertEq(tokens[0], address(erc20)); 
    }

    function _configurefee() internal {
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(feePaymentId, true);
    }

    function _configureBalanceNativeToken() internal {
        vm.deal(CCIPSENDER_ADMIN, 1 ether);
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.depositNativeTokens{value: 1 ether}();
    }

    function _configureAllowListedChain() internal {
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, false, true);
    }


    function testCanTransferTokens() public {
        uint256 ERC20_SENDER_BALANCE = 2000;
        // arrange
        // Step 0 - token balance
        erc20.mint(CCIPSENDER_ADMIN,ERC20_SENDER_BALANCE);
        // Step 1 - configure fee
         _configurefee();
        // Step 2 - Configure balance native token
        _configureBalanceNativeToken();
        // Step 3 - configure destination chain
         _configureAllowListedChain();
        uint256 value = 1000;
        // Step 4 - configure allowance
        vm.prank(CCIPSENDER_ADMIN);
        erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        bytes32 messageId = CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(erc20), value, 0);
       // assertEq(tokens[0], address(erc20)); 
               
        // Check messageId
        // Arrange
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](1);
        _tokens[0] = address(erc20);
        _amounts[0] = value;
        
        // Assert messageId
        Client.EVMTokenAmount[] memory tokenAmounts = CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
        
        bytes32 mockMsgId =  keccak256(abi.encode(CCIPSENDER_CONTRACT.buildCCIPTransferMessage(RECEIVER_ADDRESS, tokenAmounts, 0)));
        assertEq(messageId, mockMsgId); 
    }

    function testCanTransferTokensBatch() public {
        ERC20Mock erc20Second = new ERC20Mock();
        uint256 value = 1000;
        uint256 valueSecond = 2000;
        address[] memory _tokens = new address[](2);
        uint256[] memory _amounts = new uint256[](2);
        _tokens[0] = address(erc20Second);
        _tokens[1] = address( erc20);
        _amounts[0] = valueSecond;
        _amounts[1] = value ;

        // arrange
        // Step 0 - token balance
        erc20.mint(CCIPSENDER_ADMIN,value);
        erc20Second.mint(CCIPSENDER_ADMIN,valueSecond);
             
        _configureBalanceNativeToken();
        // Step 1 - configure fee
         _configurefee();
        // Step 2 - Configure balance native token
        _configureBalanceNativeToken();
        // Step 3 - configure destination chain
         _configureAllowListedChain();
   
        // Step 4 - configure allowance
        vm.prank(CCIPSENDER_ADMIN);
        erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        erc20Second.approve(address(CCIPSENDER_CONTRACT), valueSecond);
        vm.prank(CCIPSENDER_ADMIN);
        bytes32 messageId = CCIPSENDER_CONTRACT.transferTokensBatch(AVALANCHE_SELECTOR, RECEIVER_ADDRESS,  _tokens, _amounts, feePaymentId);
               
        // Check messageId
        
        // Assert messageId
        Client.EVMTokenAmount[] memory tokenAmounts = CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
        
        bytes32 mockMsgId =  keccak256(abi.encode(CCIPSENDER_CONTRACT.buildCCIPTransferMessage(RECEIVER_ADDRESS, tokenAmounts, feePaymentId)));
        assertEq(messageId, mockMsgId); 
    }

    function testCannotTransferTokensIfContractHasNotEnoughFee() public {
        uint256 ERC20_SENDER_BALANCE = 2000;
        // arrange
        // Step 0 - token balance
        erc20.mint(CCIPSENDER_ADMIN,ERC20_SENDER_BALANCE);
        // Step 1 - configure fee
         _configurefee();
        // Step 2 - we do not do the deposit
        //_configureBalanceNativeToken();
        // Step 3 - configure destination chain
        _configureAllowListedChain();
        uint256 value = 1000;
        // Step 4 - configure allowance
        vm.prank(CCIPSENDER_ADMIN);
        erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderPayment_ContractNotEnoughBalance.selector, address(CCIPSENDER_CONTRACT).balance, 10 ));
        CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(erc20), value, feePaymentId);
    }

    function testCannotTransferTokensIfFeesAreNotConfigured() public {
        uint256 ERC20_SENDER_BALANCE = 2000;
        // arrange
        // Step 0 - token balance
        erc20.mint(CCIPSENDER_ADMIN,ERC20_SENDER_BALANCE);
        // Step 1 - configure fee
        // _configurefee();
        // Step 2 - we do not do the deposit
        //_configureBalanceNativeToken();
        // Step 3 - configure destination chain
        _configureAllowListedChain();
        uint256 value = 1000;
        // Step 4 - configure allowance
        vm.prank(CCIPSENDER_ADMIN);
        erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_SenderBuild_InvalidFeeId.selector));
        CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(erc20), value, feePaymentId);
    }


    function testCannotTransferTokensIfDestinationChainIsNotAllowlisted() public {
        uint256 ERC20_SENDER_BALANCE = 2000;
        // arrange
        // Step 0 - token balance
        erc20.mint(CCIPSENDER_ADMIN,ERC20_SENDER_BALANCE);
        // Step 1 - configure fee
        _configurefee();
        // Step 2 - we do not do the deposit
        _configureBalanceNativeToken();
        // Step 3 - configure destination chain
        //        vm.prank(CCIPSENDER_ADMIN);
        //CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, false, true);
        uint256 value = 1000;
        // Step 4 - configure allowance
        vm.prank(CCIPSENDER_ADMIN);
        erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        vm.expectRevert(
        abi.encodeWithSelector(CCIPErrors.CCIP_AllowListedChain_DestinationChainNotAllowlisted.selector, AVALANCHE_SELECTOR));
        CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(erc20), value, feePaymentId);
    }
    function testCannotTransferTokensIfTokensAllowanceNotEnough() public {
        uint256 ERC20_SENDER_BALANCE = 2000;
        // arrange
        // Step 0 - token balance
        erc20.mint(CCIPSENDER_ADMIN,ERC20_SENDER_BALANCE);
        // Step 1 - configure fee
        _configurefee();
        // Step 2 - we do not do the deposit
        _configureBalanceNativeToken();
        // Step 3 - configure destination chain
        _configureAllowListedChain();
        uint256 value = 1000;
        // Step 4 - configure allowance
        // vm.prank(CCIPSENDER_ADMIN);
        //erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        vm.expectRevert(
        abi.encodeWithSelector(ERC20InsufficientAllowance.selector, address(CCIPSENDER_CONTRACT), 0, value));
        CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(erc20), value, feePaymentId);
    }

    function testCannotTransferTokensIfSenderBalanceNotEnough() public {
        // arrange
        // Step 0 - token balance
        //erc20.mint(CCIPSENDER_ADMIN,ERC20_SENDER_BALANCE);
        // Step 1 - configure fee
        _configurefee();
        // Step 2 - we do not do the deposit
        _configureBalanceNativeToken();
        // Step 3 - configure destination chain
        _configureAllowListedChain();
        uint256 value = 1000;
        // Step 4 - configure allowance
        vm.prank(CCIPSENDER_ADMIN);
        erc20.approve(address(CCIPSENDER_CONTRACT), value);
        vm.prank(CCIPSENDER_ADMIN);
        vm.expectRevert(
        abi.encodeWithSelector(ERC20InsufficientBalance.selector, 0x9, 0, value));
        CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(erc20), value, feePaymentId);
    }
}