// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library CCIPErrors {
     // Custom errors to provide more descriptive revert messages.
    error CCIP_NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    // Used when the destination chain has not been allowlisted by the contract owner.
    error CCIP_CCIPAllowListedChain_DestinationChainNotAllowlisted(uint64 destinationChainSelector); 
    // Used when the source chain has not been allowlisted by the contract owner.
    error CCIP_CCIPAllowListedChain_SourceChainNotAllowlisted(uint64 sourceChainSelector); 


    // CCIPBaseReceiverDefensive
     error CCIP_CCIPReceiverDefensiveNotRightSender();

    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
    error SourceChainNotAllowed(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
    error SenderNotAllowed(address sender); // Used when the sender has not been allowlisted by the contract owner.
    error OnlySelf(); // Used when a function is called outside of the contract itself.
    error ErrorCase(); // Used when simulating a revert during message processing.
    error MessageNotFailed(bytes32 messageId);


}