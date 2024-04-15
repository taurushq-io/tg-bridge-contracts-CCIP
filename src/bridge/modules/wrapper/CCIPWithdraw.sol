// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {SafeERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "ccip-v08/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import "../libraries/CCIPErrors.sol";
import "../security/AuthorizationModule.sol";
abstract contract CCIPWithdraw  is AuthorizationModule   {
    using SafeERC20 for IERC20;

    /// @notice Fallback function to allow the contract to receive native tokens (e.g. Ether).
    /// @dev This function has no function body, making it a default function for receiving native token.
    /// It is automatically called when native token is transferred to the contract without any data.
    receive() external payable {}

    /**
    * @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token, use for example, to pay the gas fee
    * @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    * @param _beneficiary The address to which the tokens will be sent.
    * @param _token The contract address of the ERC20 token to be withdrawn.
    */
    function withdrawToken(
        address _beneficiary,
        address _token,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if(_beneficiary == address(0)){
            revert CCIPErrors.CCIP_Withdraw_Address_Zero_Not_Allowed();
        }
        if( _amount == 0){
              _amount = IERC20(_token).balanceOf(address(this));
             if ( _amount == 0) {
                revert CCIPErrors.CCIP_Withdraw_NothingToWithdraw();
            }
        }
        // External call
        IERC20(_token).safeTransfer(
           _beneficiary,  _amount
        );
    }
    /**
    * @notice withdraw native tokens
    * @param _beneficiary token receiver
    * @param _amount value to transfer, if 0, send all contracts balance.
    */
    function withdrawNativeToken(address _beneficiary, uint256  _amount) public onlyRole(DEFAULT_ADMIN_ROLE){
        if(_beneficiary == address(0)){
            revert CCIPErrors.CCIP_Withdraw_Address_Zero_Not_Allowed();
        }
        if( _amount == 0){
              _amount = address(this).balance;
             if ( _amount == 0) {
                revert CCIPErrors.CCIP_Withdraw_NothingToWithdraw();
            }
        }
        // External call
        (bool success,)= _beneficiary.call{value:_amount}("");
        if(!success){
            revert CCIPErrors.CCIP_Withdraw_FailedToWithdrawEth(_msgSender(), _beneficiary,  _amount);
        }
    }
}