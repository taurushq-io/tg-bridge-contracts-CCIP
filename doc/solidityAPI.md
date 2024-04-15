# Solidity API

## CCIPBaseReceiver

### MessageReceived

```solidity
event MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender, string text, address token, uint256 tokenAmount)
```

### ccipReceive

```solidity
function ccipReceive(struct Client.Any2EVMMessage any2EvmMessage) external
```

The entrypoint for the CCIP router to call. This function should
never revert, all errors should be handled internally in this contract.

_Extremely important to ensure only router calls this._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| any2EvmMessage | struct Client.Any2EVMMessage | The message to process. |

### processMessage

```solidity
function processMessage(struct Client.Any2EVMMessage any2EvmMessage) external
```

Serves as the entry point for this contract to process incoming messages.

_Transfers specified token amounts to the owner of this contract. This function
must be external because of the  try/catch for error handling.
It uses the `onlySelf`: can only be called from the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| any2EvmMessage | struct Client.Any2EVMMessage | Received CCIP message. |

### _ccipReceive

```solidity
function _ccipReceive(struct Client.Any2EVMMessage any2EvmMessage) internal
```

handle a received message

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool)
```

## CCIPBaseSender

### TokenSingleTransferred

```solidity
event TokenSingleTransferred(bytes32 messageId, uint64 destinationChainSelector, address receiver, address token, uint256 tokenAmount, uint256 _paymentMethodId, uint256 fees)
```

### TokensBatchTransferred

```solidity
event TokensBatchTransferred(bytes32 messageId, uint64 destinationChainSelector, address receiver, address[] tokens, uint256[] tokenAmounts, uint256 _paymentMethodId, uint256 fees)
```

### transferTokens

```solidity
function transferTokens(uint64 _destinationChainSelector, address _receiver, address _token, uint256 _amount, uint256 _paymentMethodId) external returns (bytes32 messageId)
```

### transferTokensBatch

```solidity
function transferTokensBatch(uint64 _destinationChainSelector, address _receiver, address[] _tokens, uint256[] _amounts, uint256 _paymentMethodId) external returns (bytes32 messageId)
```

transfer tokens

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _destinationChainSelector | uint64 |  |
| _receiver | address | address on the destination blockchain |
| _tokens | address[] | token contract on the source chain |
| _amounts | uint256[] | token amount to transfer |
| _paymentMethodId | uint256 |  |

### buildEndSend

```solidity
function buildEndSend(uint64 _destinationChainSelector, address _receiver, uint256 _paymentMethodId, struct Client.EVMTokenAmount[] tokenAmounts) internal returns (uint256 fees, bytes32 messageId)
```

buildEndSend

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _destinationChainSelector | uint64 | Id selector for the destination blockchain |
| _receiver | address | address on the destination blockchain |
| _paymentMethodId | uint256 | id to select the payment |
| tokenAmounts | struct Client.EVMTokenAmount[] | array for each token |

## CCIPAllowlistedChain

### allowlistedDestinationChains

```solidity
mapping(uint64 => bool) allowlistedDestinationChains
```

### allowlistedSourceChains

```solidity
mapping(uint64 => bool) allowlistedSourceChains
```

### onlyAllowlistedDestinationChain

```solidity
modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector)
```

_Modifier that checks if the chain with the given destinationChainSelector is allowlisted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _destinationChainSelector | uint64 | The selector of the destination chain. |

### onlyAllowlisted

```solidity
modifier onlyAllowlisted(uint64 _sourceChainSelector)
```

_Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _sourceChainSelector | uint64 | The selector of the destination chain. |

### setAllowlistChain

```solidity
function setAllowlistChain(uint64 _chainSelector, bool allowedSourceChain, bool allowedDestinationChain) external
```

Updates the allowlist status of chain for transactions (source and destination).

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _chainSelector | uint64 | selector from CCIP |
| allowedSourceChain | bool | boolean to add(true) or remove(false) the selected blockchain |
| allowedDestinationChain | bool | boolean to add(true) or remove(false) the selected blockchain |

## CCIPRouterManage

### i_router

```solidity
address i_router
```

### constructor

```solidity
constructor(address router) internal
```

### getRouter

```solidity
function getRouter() public view returns (address)
```

Return the current router

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | i_router address |

### getSupportedTokens

```solidity
function getSupportedTokens(uint64 chainSelector) external view returns (address[] tokens)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| chainSelector | uint64 | blockchain selector |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokens | address[] | list of contract address for all supported tokens |

### onlyRouter

```solidity
modifier onlyRouter()
```

_only calls from the set router are accepted._

## CCIPSenderPayment

### FEE_PAYMENT_TOKEN

```solidity
struct FEE_PAYMENT_TOKEN {
  uint256 id;
  string label;
  bool isActivate;
  contract IERC20 tokenAddress;
}
```

### paymentTokens

```solidity
mapping(uint256 => struct CCIPSenderPayment.FEE_PAYMENT_TOKEN) paymentTokens
```

### tokenPaymentConfigured

```solidity
mapping(address => bool) tokenPaymentConfigured
```

### setFeePaymentMethod

```solidity
function setFeePaymentMethod(contract IERC20 tokenAddress_, string label_) public
```

set the fee payment

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenAddress_ | contract IERC20 | Token address, ERC-20 |
| label_ | string | token label, e.g. "USDC" |

### isValidPaymentId

```solidity
function isValidPaymentId(uint256 id) internal view returns (bool)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | paymentId |

### changeStatusFeePaymentMethod

```solidity
function changeStatusFeePaymentMethod(uint256 id, bool newState) public
```

set the fee payment

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | token Id |
| newState | bool | boolean. True to activate, false to deactivate |

### _computeAndApproveFee

```solidity
function _computeAndApproveFee(uint64 _destinationChainSelector, struct Client.EVM2AnyMessage message, contract IRouterClient router, uint256 paymentMethodId) internal returns (uint256)
```

## CCIPReceiverInternal

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool)
```

IERC165 supports an interfaceId

_Should indicate whether the contract implements IAny2EVMMessageReceiver
e.g. return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId
This allows CCIP to check if ccipReceive is available before calling it.
If this returns false or reverts, only tokens are transferred to the receiver.
If this returns true, tokens are transferred and ccipReceive is called atomically.
Additionally, if the receiver address does not have code associated with
it at the time of execution (EXTCODESIZE returns 0), only tokens will be transferred._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| interfaceId | bytes4 | The interfaceId to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true if the interfaceId is supported |

### _ccipReceive

```solidity
function _ccipReceive(struct Client.Any2EVMMessage message) internal virtual
```

Override this function in your implementation.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | struct Client.Any2EVMMessage | Any2EVMMessage |

## CCIPErrors

### CCIP_Admin_Address_Zero_Not_Allowed

```solidity
error CCIP_Admin_Address_Zero_Not_Allowed()
```

### CCIP_Router_Address_Zero_Not_Allowed

```solidity
error CCIP_Router_Address_Zero_Not_Allowed()
```

### CCIP_Router_InvalidRouter

```solidity
error CCIP_Router_InvalidRouter(address routerProvided)
```

### CCIP_AllowListedChain_DestinationChainNotAllowlisted

```solidity
error CCIP_AllowListedChain_DestinationChainNotAllowlisted(uint64 destinationChainSelector)
```

### CCIP_AllowListedChain_SourceChainNotAllowlisted

```solidity
error CCIP_AllowListedChain_SourceChainNotAllowlisted(uint64 sourceChainSelector)
```

### CCIP_BaseSender_FailApproval

```solidity
error CCIP_BaseSender_FailApproval()
```

### CCIP_Withdraw_NothingToWithdraw

```solidity
error CCIP_Withdraw_NothingToWithdraw()
```

### CCIP_Withdraw_FailedToWithdrawEth

```solidity
error CCIP_Withdraw_FailedToWithdrawEth(address owner, address target, uint256 value)
```

### CCIP_Withdraw_Address_Zero_Not_Allowed

```solidity
error CCIP_Withdraw_Address_Zero_Not_Allowed()
```

### OnlySelf

```solidity
error OnlySelf()
```

### CCIP_BaseReceiver_ErrorCase

```solidity
error CCIP_BaseReceiver_ErrorCase()
```

### CCIP_ReceiverDefensive_MessageNotFailed

```solidity
error CCIP_ReceiverDefensive_MessageNotFailed(bytes32 messageId)
```

### CCIP_ReceiverDefensive_NotRightSender

```solidity
error CCIP_ReceiverDefensive_NotRightSender()
```

### CCIP_SenderBuild_InvalidFeeId

```solidity
error CCIP_SenderBuild_InvalidFeeId()
```

### CCIP_SenderPayment_NotEnoughBalance

```solidity
error CCIP_SenderPayment_NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees)
```

### CCIP_SenderPayment_TokenAlreadySet

```solidity
error CCIP_SenderPayment_TokenAlreadySet()
```

### CCIP_SenderPayment_InvalidId

```solidity
error CCIP_SenderPayment_InvalidId()
```

### CCIP_SenderPayment_FailApproval

```solidity
error CCIP_SenderPayment_FailApproval()
```

## AuthorizationModule

### VALIDATOR_ROLE

```solidity
bytes32 VALIDATOR_ROLE
```

### PAUSER_ROLE

```solidity
bytes32 PAUSER_ROLE
```

### ROUTER_ROLE

```solidity
bytes32 ROUTER_ROLE
```

### BRIDGE_MESSAGE_MANAGER

```solidity
bytes32 BRIDGE_MESSAGE_MANAGER
```

Manage the failed message and transfer tokens if necessary.

_used by CCCIP Receiver Defensive_

### BRIDGE_ALLOWLISTED_CHAIN_MANAGER_ROLE

```solidity
bytes32 BRIDGE_ALLOWLISTED_CHAIN_MANAGER_ROLE
```

Can manage the different chain allowed by our bridge

### BRIDGE_USER_ROLE

```solidity
bytes32 BRIDGE_USER_ROLE
```

This role can transfers tokens through the bridge

### BRIDGE_OPERATOR_ROLE

```solidity
bytes32 BRIDGE_OPERATOR_ROLE
```

This role can transfers tokens through the bridge

### hasRole

```solidity
function hasRole(bytes32 role, address account) public view virtual returns (bool)
```

_Returns `true` if `account` has been granted `role`._

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool)
```

_See {IERC165-supportsInterface}._

## CCIPReceiverDefensive

_- This example shows how to recover tokens in case of revert_

### ErrorCode

```solidity
enum ErrorCode {
  RESOLVED,
  BASIC
}
```

### MessageFailed

```solidity
event MessageFailed(bytes32 messageId, bytes reason)
```

### MessageRecovered

```solidity
event MessageRecovered(bytes32 messageId)
```

### s_lastReceivedMessageId

```solidity
bytes32 s_lastReceivedMessageId
```

### s_lastReceivedTokenAddress

```solidity
address s_lastReceivedTokenAddress
```

### s_lastReceivedTokenAmount

```solidity
uint256 s_lastReceivedTokenAmount
```

### s_lastReceivedText

```solidity
string s_lastReceivedText
```

### s_messageContents

```solidity
mapping(bytes32 => struct Client.Any2EVMMessage) s_messageContents
```

### s_failedMessages

```solidity
struct EnumerableMap.Bytes32ToUintMap s_failedMessages
```

### s_simRevert

```solidity
bool s_simRevert
```

### onlySelf

```solidity
modifier onlySelf()
```

_Modifier to allow only the contract itself to execute a function.
Throws an exception if called by any account other than the contract itself._

### getLastReceivedMessageDetails

```solidity
function getLastReceivedMessageDetails() public view returns (bytes32 messageId, string text, address tokenAddress, uint256 tokenAmount)
```

Returns the details of the last CCIP received message.

_This function retrieves the ID, text, token address, and token amount of the last received CCIP message._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| messageId | bytes32 | The ID of the last received CCIP message. |
| text | string | The text of the last received CCIP message. |
| tokenAddress | address | The address of the token in the last CCIP received message. |
| tokenAmount | uint256 | The amount of the token in the last CCIP received message. |

### getFailedMessagesIds

```solidity
function getFailedMessagesIds() external view returns (bytes32[] ids)
```

Retrieves the IDs of failed messages from the `s_failedMessages` map.

_Iterates over the `s_failedMessages` map, collecting all keys._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| ids | bytes32[] | An array of bytes32 containing the IDs of failed messages from the `s_failedMessages` map. |

### retryFailedMessage

```solidity
function retryFailedMessage(bytes32 messageId, address tokenReceiver) external
```

Allows the owner to retry a failed message in order to unblock the associated tokens.

_This function is only callable by the contract owner. It changes the status of the message
from 'failed' to 'resolved' to prevent reentry and multiple retries of the same message._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| messageId | bytes32 | The unique identifier of the failed message. |
| tokenReceiver | address | The address to which the tokens will be sent. |

### setSimRevert

```solidity
function setSimRevert(bool simRevert) public
```

Allows the owner to toggle simulation of reversion for testing purposes.

_This function is only callable by the contract owner._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| simRevert | bool | If `true`, simulates a revert condition; if `false`, disables the simulation. |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool)
```

## CCIPSenderBuild

### _buildCCIPMessage

```solidity
function _buildCCIPMessage(address _receiver, string _text, struct Client.EVMTokenAmount[] _tokenAmounts, uint256 gasLimit_, address feeToken_) internal pure returns (struct Client.EVM2AnyMessage)
```

Construct a CCIP message.

_This function will create an EVM2AnyMessage struct with all the necessary information for sending a text._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _receiver | address | The address of the receiver. |
| _text | string |  |
| _tokenAmounts | struct Client.EVMTokenAmount[] | Value amounts of tokens to be sent |
| gasLimit_ | uint256 |  |
| feeToken_ | address |  |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct Client.EVM2AnyMessage | Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message. |

### _buildCCIPTransferMessage

```solidity
function _buildCCIPTransferMessage(address _receiver, struct Client.EVMTokenAmount[] _tokenAmounts, uint256 paymentMethodId) internal view returns (struct Client.EVM2AnyMessage)
```

Construct a CCIP message.

_This function will create an EVM2AnyMessage struct with all the necessary information for sending a text._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _receiver | address | The address of the receiver. |
| _tokenAmounts | struct Client.EVMTokenAmount[] | Value amounts of tokens to be sent |
| paymentMethodId | uint256 |  |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct Client.EVM2AnyMessage | Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message. |

### buildCCIPTransferMessage

```solidity
function buildCCIPTransferMessage(address _receiver, struct Client.EVMTokenAmount[] _tokenAmounts, uint256 paymentMethodId) public view returns (struct Client.EVM2AnyMessage)
```

Construct a CCIP message.

_This function will create an EVM2AnyMessage struct with all the necessary information for sending a text._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _receiver | address | The address of the receiver. |
| _tokenAmounts | struct Client.EVMTokenAmount[] | Value amounts of tokens to be sent |
| paymentMethodId | uint256 |  |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct Client.EVM2AnyMessage | Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message. |

### buildTokenAmounts

```solidity
function buildTokenAmounts(address[] _tokens, uint256[] _amounts) public pure returns (struct Client.EVMTokenAmount[] tokenAmounts)
```

## CCIPWithdraw

### receive

```solidity
receive() external payable
```

Fallback function to allow the contract to receive native tokens (e.g. Ether).

_This function has no function body, making it a default function for receiving native token.
It is automatically called when native token is transferred to the contract without any data._

### withdrawToken

```solidity
function withdrawToken(address _beneficiary, address _token, uint256 _amount) public
```

Allows the owner of the contract to withdraw all tokens of a specific ERC20 token, use for example, to pay the gas fee

_This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _beneficiary | address | The address to which the tokens will be sent. |
| _token | address | The contract address of the ERC20 token to be withdrawn. |
| _amount | uint256 |  |

### withdrawNativeToken

```solidity
function withdrawNativeToken(address _beneficiary, uint256 _amount) public
```

withdraw native tokens

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _beneficiary | address | token receiver |
| _amount | uint256 | value to transfer, if 0, send all contracts balance. |

## CCIPSender

### constructor

```solidity
constructor(address admin, address routerIrrevocable, address forwarderIrrevocable) public
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| admin | address | Address of the contract (Access Control) |
| routerIrrevocable | address | CCIP router |
| forwarderIrrevocable | address | Address of the forwarder, required for the gasless support |

### _msgSender

```solidity
function _msgSender() internal view returns (address sender)
```

_This surcharge is not necessary if you do not use the MetaTx_

### _msgData

```solidity
function _msgData() internal view returns (bytes)
```

_This surcharge is not necessary if you do not use the MetaTx_

### _contextSuffixLength

```solidity
function _contextSuffixLength() internal view returns (uint256)
```

_This surcharge is not necessary if you do not use the MetaTx_

## CCIPSenderReceiver

### constructor

```solidity
constructor(address admin, address _router) public
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool)
```

