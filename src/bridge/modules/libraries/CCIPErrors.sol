// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library CCIPErrors {
     // Custom errors to provide more descriptive revert messages.

    error CCIP_ADMIN_ADDRESS_ZERO_NOT_ALLOWED();
    error CCIP_ROUTER_ADDRESS_ZERO_NOT_ALLOWED();
    // CCIP_CCIPAllowListedChain
    // Used when the destination chain has not been allowlisted by the contract owner.
    error CCIP_CCIPAllowListedChain_DestinationChainNotAllowlisted(uint64 destinationChainSelector); 
    // Used when the source chain has not been allowlisted by the contract owner.
    error CCIP_CCIPAllowListedChain_SourceChainNotAllowlisted(uint64 sourceChainSelector); 

    // CCIPBaseReceiverDefensive

    error CCIPWithdraw_NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error CCIPWithdraw_FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    
    
    //error SenderNotAllowed(address sender); // Used when the sender has not been allowlisted by the contract owner.
    error OnlySelf(); // Used when a function is called outside of the contract itself.
    
    error CCIP_BASE_RECEIVER_ErrorCase(); // Used when simulating a revert during message processing.
    error CCIP_RECEIVER_DEFENSIVE_MessageNotFailed(bytes32 messageId);
    error CCIP_CCIPReceiverDefensiveNotRightSender();


    // CCIP Sender Internal
    error CCIP_SENDER_BUILD_InvalidFeeId();

    // Used to make sure contract has enough balance to cover the fees.
    error CCIP_SENDER_PAYMENT_NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
}