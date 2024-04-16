// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../libraries/CCIPErrors.sol";
import "../configuration/CCIPSenderPayment.sol";
abstract contract CCIPSenderBuild is CCIPSenderPayment{

    function buildTokenAmounts(
    address[] memory _tokens,
    uint256[] memory _amounts) public pure returns (Client.EVMTokenAmount[] memory tokenAmounts){
        if( _tokens.length == 0){
            revert CCIPErrors.CCIP_SenderBuild_TokensIsEmpty();
        }
        if(_tokens.length != _amounts.length){
            revert CCIPErrors.CCIP_SenderBuild_LengthMismatch();
        }
        tokenAmounts = new Client.EVMTokenAmount[](_tokens.length);
        for(uint256 i = 0; i < _tokens.length; ++i ){
            if(_tokens[i] == address(0)){
                revert CCIPErrors.CCIP_SenderBuild_Address_Zero_Not_Allowed();
            }
            Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
                token: _tokens[i],
                amount: _amounts[i]
            });
            tokenAmounts[i] = tokenAmount;
        }
    } 

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
        address feeToken = address(0);
        if(paymentTokens[paymentMethodId].isActivate){
            feeToken = address(paymentTokens[paymentMethodId].tokenAddress);
        } else {
            revert CCIPErrors.CCIP_SenderBuild_InvalidFeeId();
        }
        return _buildCCIPMessage(_receiver, "", _tokenAmounts, 400_000, feeToken);
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
    /// @param _receiver The address of the receiver.
    /// @param _tokenAmounts Value amounts of tokens to be sent
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function buildCCIPTransferMessage(
        address _receiver,
        Client.EVMTokenAmount[] memory  _tokenAmounts,
        uint256 paymentMethodId
    ) public view returns (Client.EVM2AnyMessage memory) {
        return _buildCCIPTransferMessage(_receiver, _tokenAmounts,paymentMethodId );
    } 
}