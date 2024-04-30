// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CCIPLocalSimulator,BurnMintERC677Helper} from "chainlink-local/src/ccip/CCIPLocalSimulator.sol";
import {IRouterClient as IRouterClientSimulator} from "chainlink-local/src/ccip/CCIPLocalSimulator.sol";
import {WETH9} from "chainlink-local/src/shared/WETH9.sol";
import {LinkToken} from "chainlink-local/src/shared/LinkToken.sol";
import {Client} from "ccip/libraries/Client.sol";
import "src/deployment/CCIPSender.sol";
import "../HelperContract.sol";
contract SimulatorTest is Test, HelperContract {
    uint256 feePaymentId = 0;
    // CCIP Simulator
    CCIPLocalSimulator public ccipLocalSimulator;
    uint64 chainSelector;
    BurnMintERC677Helper ccipBnM;
    IRouterClientSimulator sourceRouter;

    function setUp() public {
        uint64 chainSelector_;
        IRouterClientSimulator sourceRouter_;
        IRouterClientSimulator destinationRouter_;
        WETH9 wrappedNative_;
        LinkToken linkToken_;
        BurnMintERC677Helper ccipBnM_;
        BurnMintERC677Helper ccipLnM_;
        // CCIP local simulator
        ccipLocalSimulator = new CCIPLocalSimulator();
        (
            chainSelector_,
            sourceRouter_,
            destinationRouter_,
            wrappedNative_,
            linkToken_,
            ccipBnM_,
            ccipLnM_

        ) = ccipLocalSimulator.configuration();

        // Sender

        // Deploy CCIP Sender
        CCIPSENDER_CONTRACT = new CCIPSender(
            CCIPSENDER_ADMIN,
            address(sourceRouter_),
            ZERO_ADDRESS
        );

        chainSelector = chainSelector_;
        ccipBnM = ccipBnM_;
        sourceRouter = sourceRouter_;
    }


    function _configureAllowListedChain() internal {
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.setAllowlistChain(AVALANCHE_SELECTOR, false, true);
    }

    function _configurefee() internal {
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.changeStatusFeePaymentMethod(feePaymentId, true);
    }

    function testCanPayInNativeTokensWithSimulator() external {
        vm.prank(CCIPSENDER_ADMIN);
        CCIPSENDER_CONTRACT.grantRole(BRIDGE_USER_ROLE, SENDER_ADDRESS);
        resBool = CCIPSENDER_CONTRACT.hasRole(BRIDGE_USER_ROLE, SENDER_ADDRESS);
        assertEq(resBool, true);
        vm.prank(SENDER_ADDRESS);
        ccipBnM.drip(SENDER_ADDRESS);
        uint256 value = 1000;

        vm.prank(SENDER_ADDRESS);
        ccipBnM.increaseApproval(address(CCIPSENDER_CONTRACT), value);
        assertEq(ccipBnM.allowance(SENDER_ADDRESS, address(CCIPSENDER_CONTRACT)), value);

        uint256 balanceOfSenderBefore = ccipBnM.balanceOf(SENDER_ADDRESS); 
        uint256 balanceOfReceiverBefore = ccipBnM.balanceOf(RECEIVER_ADDRESS);  

        _configureAllowListedChain();
        _configurefee();
        vm.prank(SENDER_ADDRESS);
        bytes32 messageId = CCIPSENDER_CONTRACT.transferTokens(AVALANCHE_SELECTOR, RECEIVER_ADDRESS, address(ccipBnM), value, feePaymentId);

        uint256 balanceOfSenderAfter = ccipBnM.balanceOf(SENDER_ADDRESS);
        uint256 balanceOfReceiverAfter = ccipBnM.balanceOf(RECEIVER_ADDRESS);
        assertEq(balanceOfSenderAfter, balanceOfSenderBefore - value);
        assertEq(balanceOfReceiverAfter, balanceOfReceiverBefore + value);

        // Check messageId
        // Arrange
        address[] memory _tokens = new address[](1);
        uint256[] memory _amounts = new uint256[](1);
        _tokens[0] = address(ccipBnM);
        _amounts[0] = value;
        
        // Assert messageId
        Client.EVMTokenAmount[] memory tokenAmounts = CCIPSENDER_CONTRACT.buildTokenAmounts(_tokens, _amounts);
        
        bytes32 mockMsgId =  keccak256(abi.encode(CCIPSENDER_CONTRACT.buildCCIPTransferMessage(RECEIVER_ADDRESS, tokenAmounts, 0)));
        assertEq(messageId, mockMsgId); 
    }
}