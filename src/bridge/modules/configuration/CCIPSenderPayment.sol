// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {Client} from "ccip/libraries/Client.sol";
import {IRouterClient} from "ccip/interfaces/IRouterClient.sol";
import "../libraries/CCIPErrors.sol";
import "../security/AuthorizationModule.sol";

abstract contract CCIPSenderPayment is AuthorizationModule{
    using SafeERC20 for IERC20;
    uint256 private paymentIdCounter = 1;
    struct FEE_PAYMENT_TOKEN {
        uint256 id;
        string label;
        bool isActivate;
        IERC20 tokenAddress;
    }
    event MessageGasLimit(uint256 newMessageGasLimit);
    event MessageData(string newMessageData);
    mapping(uint256 => FEE_PAYMENT_TOKEN) public paymentTokens;
    // List of configured payment
    mapping(address => bool) public tokenPaymentConfigured;
    /**
    * @notice
    * @dev set to zero since no receiver contract
    */
    uint256 public messageGasLimit = 0;
    /**
    * @notice
    * @dev set to empty string since no data
    */
    string public messageData = "";

    function setMessageGasLimit(uint256 messageGasLimit_) public onlyRole(BRIDGE_OPERATOR_ROLE){
        messageGasLimit = messageGasLimit_;
        emit MessageGasLimit(messageGasLimit_);
    }

    /**
    * @param messageData_ new data
    */
    function setMessageData(string memory messageData_) public onlyRole(BRIDGE_OPERATOR_ROLE){
        messageData = messageData_;
        emit MessageData(messageData_);
    }    

    /**
    * @notice set the fee payment
    * @param tokenAddress_ Token address, ERC-20
    * @param label_ token label, e.g. "USDC"
    */
    function setFeePaymentMethod(IERC20 tokenAddress_, string calldata  label_) public onlyRole(BRIDGE_OPERATOR_ROLE) {
        if(tokenPaymentConfigured[address(tokenAddress_)]){
            revert CCIPErrors.CCIP_SenderPayment_TokenAlreadySet();
        }
        paymentTokens[paymentIdCounter] = FEE_PAYMENT_TOKEN({
            id:  paymentIdCounter,
            label: label_,
            isActivate: true,
            tokenAddress: tokenAddress_
        });
        tokenPaymentConfigured[address(tokenAddress_)] = true;
        ++paymentIdCounter;
    }

    /**
    * @param id paymentId
    */
    function isValidPaymentId(uint256 id) internal view returns(bool){
        return id < paymentIdCounter ? true:false;
    }
    /**
    * @notice set the fee payment
    * @param id token Id
    * @param newState boolean. True to activate, false to deactivate
    */
    function changeStatusFeePaymentMethod(uint256 id, bool newState) public onlyRole(BRIDGE_OPERATOR_ROLE){
        if(!isValidPaymentId(id)){
            revert CCIPErrors.CCIP_SenderPayment_InvalidId();
        }
        paymentTokens[id].isActivate = newState;
    }



    function _computeAndApproveFee(uint64 _destinationChainSelector, Client.EVM2AnyMessage memory message,  IRouterClient router, uint256 paymentMethodId ) internal returns(uint256){
        // external call
        uint256 fees = router.getFee(_destinationChainSelector, message);
        if(address(paymentTokens[paymentMethodId].tokenAddress) != address(0)){
            // ERC-20 token
            // External call
            uint256 contractBalance = paymentTokens[paymentMethodId].tokenAddress.balanceOf(address(this));
            if (fees > contractBalance){
                revert CCIPErrors.CCIP_SenderPayment_ContractNotEnoughBalance(contractBalance, fees);
            }
            // External call
            paymentTokens[paymentMethodId].tokenAddress.safeIncreaseAllowance(address(router), fees);
        } else { // Native token
            uint256 contractBalance = address(this).balance;
            if (fees > contractBalance){
                revert CCIPErrors.CCIP_SenderPayment_ContractNotEnoughBalance(contractBalance, fees);
            }
        }
        return fees;
    }
}