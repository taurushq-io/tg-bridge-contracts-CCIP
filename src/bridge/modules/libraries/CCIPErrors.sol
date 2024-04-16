// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library CCIPErrors {
     // Custom errors to provide more descriptive revert messages.

    error CCIP_Admin_Address_Zero_Not_Allowed();

    //Router
    error CCIP_Router_Address_Zero_Not_Allowed();
    error CCIP_Router_InvalidRouter(address routerProvided);
    // CCIP_CCIPAllowListedChain
    // Used when the destination chain has not been allowlisted by the contract owner.
    error CCIP_AllowListedChain_DestinationChainNotAllowlisted(uint64 destinationChainSelector); 
    // Used when the source chain has not been allowlisted by the contract owner.
    error CCIP_AllowListedChain_SourceChainNotAllowlisted(uint64 sourceChainSelector); 

    error CCIP_BaseSender_FailApproval();

    error CCIP_ContractBalance_NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error CCIP_ContractBalance_FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    error CCIP_ContractBalance_Address_Zero_Not_Allowed();
    error CCIP_ContractBalance_DepositNotPossibleWithGasless();
    
    //error SenderNotAllowed(address sender); // Used when the sender has not been allowlisted by the contract owner.
    error OnlySelf(); // Used when a function is called outside of the contract itself.
    
    error CCIP_BaseReceiver_ErrorCase(); // Used when simulating a revert during message processing.

    error CCIP_ReceiverDefensive_MessageNotFailed(bytes32 messageId);
    error CCIP_ReceiverDefensive_NotRightSender();


    // CCIP Sender Internal
    error CCIP_SenderBuild_InvalidFeeId();
    error CCIP_SenderBuild_LengthMismatch();
    error CCIP_SenderBuild_Address_Zero_Not_Allowed();
    error CCIP_SenderBuild_TokensIsEmpty();

    // Used to make sure contract has enough balance to cover the fees.
    error CCIP_SenderPayment_NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    error CCIP_SenderPayment_TokenAlreadySet(); 
    error CCIP_SenderPayment_InvalidId(); 
    error CCIP_SenderPayment_FailApproval();
} 