// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../libraries/CCIPErrors.sol";
import "../configuration/CCIPSenderPayment.sol";
abstract contract CCIPSenderBuild is CCIPSenderPayment{

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
    /// @param _receiver The address of the receiver.
    /// @param _tokenAmounts Value amounts of tokens to be sent
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        string memory _text,
        Client.EVMTokenAmount[] memory  _tokenAmounts,
        uint256 gasLimit_,
        address feeToken_
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        return Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_text),
            tokenAmounts: _tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: gasLimit_})
            ),
            feeToken: feeToken_
        });
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
    /// @param _receiver The address of the receiver.
    /// @param _tokenAmounts Value amounts of tokens to be sent
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPTransferMessage(
        address _receiver,
        Client.EVMTokenAmount[] memory  _tokenAmounts,
        uint256 paymentMethodId
    ) internal view returns (Client.EVM2AnyMessage memory) {
        address feeToken;
        if(paymentTokens[paymentMethodId].isActivate){
            feeToken = address(paymentTokens[paymentMethodId].tokenAddress);
        } else {
            revert CCIPErrors.CCIP_SENDER_BUILD_InvalidFeeId();
        }
        return _buildCCIPMessage(_receiver, "", _tokenAmounts, 400_000, feeToken);
    }
}