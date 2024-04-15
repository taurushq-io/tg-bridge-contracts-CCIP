**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [arbitrary-send-eth](#arbitrary-send-eth) (1 results) (High)
 - [incorrect-equality](#incorrect-equality) (2 results) (Medium)
 - [unused-return](#unused-return) (3 results) (Medium)
 - [reentrancy-benign](#reentrancy-benign) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (4 results) (Low)
 - [pragma](#pragma) (1 results) (Informational)
 - [dead-code](#dead-code) (1 results) (Informational)
 - [solc-version](#solc-version) (3 results) (Informational)
 - [low-level-calls](#low-level-calls) (1 results) (Informational)
 - [naming-convention](#naming-convention) (25 results) (Informational)
## arbitrary-send-eth

> The function is protected by an access control

Impact: High
Confidence: Medium

 - [ ] ID-0
	[CCIPWithdraw.withdrawNativeToken(address,uint256)](src/bridge/modules/wrapper/CCIPWithdraw.sol#L45-L60) sends eth to arbitrary user
	Dangerous calls:
	- [(success,None) = _beneficiary.call{value: _amount}()](src/bridge/modules/wrapper/CCIPWithdraw.sol#L56)

src/bridge/modules/wrapper/CCIPWithdraw.sol#L45-L60

## incorrect-equality

> It is the goal. We perform specific actions only if amount is strictly equal to zero.

Impact: Medium
Confidence: High
 - [ ] ID-1
	[CCIPWithdraw.withdrawToken(address,address,uint256)](src/bridge/modules/wrapper/CCIPWithdraw.sol#L21-L39) uses a dangerous strict equality:
	- [_amount == 0](src/bridge/modules/wrapper/CCIPWithdraw.sol#L31)

src/bridge/modules/wrapper/CCIPWithdraw.sol#L21-L39


 - [ ] ID-2
	[CCIPWithdraw.withdrawNativeToken(address,uint256)](src/bridge/modules/wrapper/CCIPWithdraw.sol#L45-L60) uses a dangerous strict equality:
	- [_amount == 0](src/bridge/modules/wrapper/CCIPWithdraw.sol#L51)

src/bridge/modules/wrapper/CCIPWithdraw.sol#L45-L60

## unused-return

>  CCIPReceiver is still in development

Impact: Medium
Confidence: Medium
 - [ ] ID-3
[CCIPBaseReceiver.ccipReceive(Client.Any2EVMMessage)](src/bridge/CCIPBaseReceiver.sol#L33-L59) ignores return value by [s_failedMessages.set(any2EvmMessage.messageId,uint256(ErrorCode.BASIC))](src/bridge/CCIPBaseReceiver.sol#L49-L52)

src/bridge/CCIPBaseReceiver.sol#L33-L59


 - [ ] ID-4
[CCIPReceiverDefensive.getFailedMessagesIds()](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L91-L103) ignores return value by [(key,None) = s_failedMessages.at(i)](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L99)

src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L91-L103


 - [ ] ID-5
[CCIPReceiverDefensive.retryFailedMessage(bytes32,address)](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L111-L134) ignores return value by [s_failedMessages.set(messageId,uint256(ErrorCode.RESOLVED))](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L120)

src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L111-L134

## reentrancy-benign

> CCIPReceiver is still in development

Impact: Low
Confidence: Medium

 - [ ] ID-6
	Reentrancy in [CCIPBaseReceiver.ccipReceive(Client.Any2EVMMessage)](src/bridge/CCIPBaseReceiver.sol#L33-L59):
	External calls:
	- [this.processMessage(any2EvmMessage)](src/bridge/CCIPBaseReceiver.sol#L44-L58)
	State variables written after the call(s):
	- [s_messageContents[any2EvmMessage.messageId] = any2EvmMessage](src/bridge/CCIPBaseReceiver.sol#L53)

src/bridge/CCIPBaseReceiver.sol#L33-L59

## reentrancy-events

> Only events are emitted after the events, and we don't care about events.

Impact: Low
Confidence: Medium
 - [ ] ID-7
	Reentrancy in [CCIPBaseSender.transferTokensBatch(uint64,address,address[],uint256[],uint256)](src/bridge/CCIPBaseSender.sol#L79-L103):
	External calls:
	- [(fees,messageId) = buildEndSend(_destinationChainSelector,_receiver,_paymentMethodId,tokenAmounts)](src/bridge/CCIPBaseSender.sol#L92)
		- [result = paymentTokens[paymentMethodId].tokenAddress.approve(address(router),fees)](src/bridge/modules/configuration/CCIPSenderPayment.sol#L70)
		- [result = IERC20(tokenAmounts[i].token).approve(address(router),tokenAmounts[i].amount)](src/bridge/CCIPBaseSender.sol#L121)
		- [messageId = router.ccipSend(_destinationChainSelector,message)](src/bridge/CCIPBaseSender.sol#L127)
		Event emitted after the call(s):
	- [TokensBatchTransferred(messageId,_destinationChainSelector,_receiver,_tokens,_amounts,_paymentMethodId,fees)](src/bridge/CCIPBaseSender.sol#L94-L102)

src/bridge/CCIPBaseSender.sol#L79-L103


 - [ ] ID-8
	Reentrancy in [CCIPReceiverDefensive.retryFailedMessage(bytes32,address)](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L111-L134):
	External calls:
	- [IERC20(message.destTokenAmounts[0].token).safeTransfer(tokenReceiver,message.destTokenAmounts[0].amount)](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L127-L130)
	Event emitted after the call(s):
	- [MessageRecovered(messageId)](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L133)

src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L111-L134


 - [ ] ID-9
	Reentrancy in [CCIPBaseSender.transferTokens(uint64,address,address,uint256,uint256)](src/bridge/CCIPBaseSender.sol#L41-L71):
	External calls:
	- [(fees,messageId) = buildEndSend(_destinationChainSelector,_receiver,_paymentMethodId,tokenAmounts)](src/bridge/CCIPBaseSender.sol#L60)
		- [result = paymentTokens[paymentMethodId].tokenAddress.approve(address(router),fees)](src/bridge/modules/configuration/CCIPSenderPayment.sol#L70)
		- [result = IERC20(tokenAmounts[i].token).approve(address(router),tokenAmounts[i].amount)](src/bridge/CCIPBaseSender.sol#L121)
		- [messageId = router.ccipSend(_destinationChainSelector,message)](src/bridge/CCIPBaseSender.sol#L127)
		Event emitted after the call(s):
	- [TokenSingleTransferred(messageId,_destinationChainSelector,_receiver,_token,_amount,_paymentMethodId,fees)](src/bridge/CCIPBaseSender.sol#L62-L70)

src/bridge/CCIPBaseSender.sol#L41-L71


 - [ ] ID-10
	Reentrancy in [CCIPBaseReceiver.ccipReceive(Client.Any2EVMMessage)](src/bridge/CCIPBaseReceiver.sol#L33-L59):
	External calls:
	- [this.processMessage(any2EvmMessage)](src/bridge/CCIPBaseReceiver.sol#L44-L58)
	Event emitted after the call(s):
	- [MessageFailed(any2EvmMessage.messageId,err)](src/bridge/CCIPBaseReceiver.sol#L56)

src/bridge/CCIPBaseReceiver.sol#L33-L59


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-11
	3 different versions of Solidity are used:
	- Version constraint ^0.8.0 is used by:
 		- lib/ccip/contracts/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol#2
		- lib/ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol#2
		- lib/ccip/contracts/src/v0.8/ccip/libraries/Client.sol#2
		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol#4
		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/extensions/draft-IERC20Permit.sol#4
		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol#4
		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/introspection/IERC165.sol#4
		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableMap.sol#5
		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableSet.sol#5
		- src/bridge/modules/configuration/CCIPRouterManage.sol#2
		- src/bridge/modules/internal/CCIPReceiverInternal.sol#2
	- Version constraint ^0.8.1 is used by:
 		- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/Address.sol#4
	- Version constraint ^0.8.20 is used by:
 		- lib/openzeppelin-contracts/contracts/access/AccessControl.sol#4
		- lib/openzeppelin-contracts/contracts/access/IAccessControl.sol#4
		- lib/openzeppelin-contracts/contracts/metatx/ERC2771Context.sol#4
		- lib/openzeppelin-contracts/contracts/utils/Context.sol#4
		- lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4
		- lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4
		- src/bridge/CCIPBaseReceiver.sol#2
		- src/bridge/CCIPBaseSender.sol#2
		- src/bridge/modules/configuration/CCIPAllowlistedChain.sol#2
		- src/bridge/modules/configuration/CCIPSenderPayment.sol#2
		- src/bridge/modules/libraries/CCIPErrors.sol#3
		- src/bridge/modules/security/AuthorizationModule.sol#3
		- src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#2
		- src/bridge/modules/wrapper/CCIPSenderBuild.sol#2
		- src/bridge/modules/wrapper/CCIPWithdraw.sol#2
		- src/deployment/CCIPSender.sol#2
		- src/deployment/CCIPSenderReceiver.sol#2

## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-12
[CCIPSender._msgData()](src/deployment/CCIPSender.sol#L37-L44) is never used and should be removed

src/deployment/CCIPSender.sol#L37-L44


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-13
Version constraint ^0.8.1 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
 It is used by:
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/Address.sol#4

 - [ ] ID-14
Version constraint ^0.8.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
 It is used by:
	- lib/ccip/contracts/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol#2
	- lib/ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol#2
	- lib/ccip/contracts/src/v0.8/ccip/libraries/Client.sol#2
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol#4
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/extensions/draft-IERC20Permit.sol#4
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol#4
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/introspection/IERC165.sol#4
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableMap.sol#5
	- lib/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableSet.sol#5
	- src/bridge/modules/configuration/CCIPRouterManage.sol#2
	- src/bridge/modules/internal/CCIPReceiverInternal.sol#2

 - [ ] ID-15
	Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
	 It is used by:
	- lib/openzeppelin-contracts/contracts/access/AccessControl.sol#4
	- lib/openzeppelin-contracts/contracts/access/IAccessControl.sol#4
	- lib/openzeppelin-contracts/contracts/metatx/ERC2771Context.sol#4
	- lib/openzeppelin-contracts/contracts/utils/Context.sol#4
	- lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4
	- lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4
	- src/bridge/CCIPBaseReceiver.sol#2
	- src/bridge/CCIPBaseSender.sol#2
	- src/bridge/modules/configuration/CCIPAllowlistedChain.sol#2
	- src/bridge/modules/configuration/CCIPSenderPayment.sol#2
	- src/bridge/modules/libraries/CCIPErrors.sol#3
	- src/bridge/modules/security/AuthorizationModule.sol#3
	- src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#2
	- src/bridge/modules/wrapper/CCIPSenderBuild.sol#2
	- src/bridge/modules/wrapper/CCIPWithdraw.sol#2
	- src/deployment/CCIPSender.sol#2
	- src/deployment/CCIPSenderReceiver.sol#2

## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-16
	Low level call in [CCIPWithdraw.withdrawNativeToken(address,uint256)](src/bridge/modules/wrapper/CCIPWithdraw.sol#L45-L60):
	- [(success,None) = _beneficiary.call{value: _amount}()](src/bridge/modules/wrapper/CCIPWithdraw.sol#L56)

src/bridge/modules/wrapper/CCIPWithdraw.sol#L45-L60


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-17
Parameter [CCIPBaseSender.transferTokens(uint64,address,address,uint256,uint256)._paymentMethodId](src/bridge/CCIPBaseSender.sol#L46) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L46


 - [ ] ID-18
Parameter [CCIPSenderBuild.buildCCIPTransferMessage(address,Client.EVMTokenAmount[],uint256)._receiver](src/bridge/modules/wrapper/CCIPSenderBuild.sol#L55) is not in mixedCase

src/bridge/modules/wrapper/CCIPSenderBuild.sol#L55


 - [ ] ID-19
Parameter [CCIPSenderBuild.buildCCIPTransferMessage(address,Client.EVMTokenAmount[],uint256)._tokenAmounts](src/bridge/modules/wrapper/CCIPSenderBuild.sol#L56) is not in mixedCase

src/bridge/modules/wrapper/CCIPSenderBuild.sol#L56


 - [ ] ID-20
Variable [CCIPReceiverDefensive.s_messageContents](src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L39-L40) is not in mixedCase

src/bridge/modules/wrapper/CCIPReceiverDefensive.sol#L39-L40


 - [ ] ID-21
Parameter [CCIPBaseSender.transferTokens(uint64,address,address,uint256,uint256)._destinationChainSelector](src/bridge/CCIPBaseSender.sol#L42) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L42


 - [ ] ID-22
Parameter [CCIPWithdraw.withdrawToken(address,address,uint256)._amount](src/bridge/modules/wrapper/CCIPWithdraw.sol#L24) is not in mixedCase

src/bridge/modules/wrapper/CCIPWithdraw.sol#L24


 - [ ] ID-23
Parameter [CCIPBaseSender.transferTokensBatch(uint64,address,address[],uint256[],uint256)._tokens](src/bridge/CCIPBaseSender.sol#L82) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L82


 - [ ] ID-24
Parameter [CCIPWithdraw.withdrawToken(address,address,uint256)._token](src/bridge/modules/wrapper/CCIPWithdraw.sol#L23) is not in mixedCase

src/bridge/modules/wrapper/CCIPWithdraw.sol#L23


 - [ ] ID-25
Parameter [CCIPBaseSender.transferTokensBatch(uint64,address,address[],uint256[],uint256)._receiver](src/bridge/CCIPBaseSender.sol#L81) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L81


 - [ ] ID-26
Parameter [CCIPWithdraw.withdrawNativeToken(address,uint256)._beneficiary](src/bridge/modules/wrapper/CCIPWithdraw.sol#L45) is not in mixedCase

src/bridge/modules/wrapper/CCIPWithdraw.sol#L45


 - [ ] ID-27
Parameter [CCIPBaseSender.buildEndSend(uint64,address,uint256,Client.EVMTokenAmount[])._destinationChainSelector](src/bridge/CCIPBaseSender.sol#L112) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L112


 - [ ] ID-28
Parameter [CCIPBaseSender.transferTokensBatch(uint64,address,address[],uint256[],uint256)._amounts](src/bridge/CCIPBaseSender.sol#L83) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L83


 - [ ] ID-29
Parameter [CCIPBaseSender.buildEndSend(uint64,address,uint256,Client.EVMTokenAmount[])._receiver](src/bridge/CCIPBaseSender.sol#L112) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L112


 - [ ] ID-30
Parameter [CCIPBaseSender.transferTokens(uint64,address,address,uint256,uint256)._token](src/bridge/CCIPBaseSender.sol#L44) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L44


 - [ ] ID-31
Parameter [CCIPWithdraw.withdrawToken(address,address,uint256)._beneficiary](src/bridge/modules/wrapper/CCIPWithdraw.sol#L22) is not in mixedCase

src/bridge/modules/wrapper/CCIPWithdraw.sol#L22


 - [ ] ID-32
Parameter [CCIPWithdraw.withdrawNativeToken(address,uint256)._amount](src/bridge/modules/wrapper/CCIPWithdraw.sol#L45) is not in mixedCase

src/bridge/modules/wrapper/CCIPWithdraw.sol#L45


 - [ ] ID-33
Parameter [CCIPSenderBuild.buildTokenAmounts(address[],uint256[])._amounts](src/bridge/modules/wrapper/CCIPSenderBuild.sol#L64) is not in mixedCase

src/bridge/modules/wrapper/CCIPSenderBuild.sol#L64


 - [ ] ID-34
Struct [CCIPSenderPayment.FEE_PAYMENT_TOKEN](src/bridge/modules/configuration/CCIPSenderPayment.sol#L12-L17) is not in CapWords

src/bridge/modules/configuration/CCIPSenderPayment.sol#L12-L17


 - [ ] ID-35
Parameter [CCIPBaseSender.transferTokensBatch(uint64,address,address[],uint256[],uint256)._paymentMethodId](src/bridge/CCIPBaseSender.sol#L84) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L84


 - [ ] ID-36
Parameter [CCIPSenderBuild.buildTokenAmounts(address[],uint256[])._tokens](src/bridge/modules/wrapper/CCIPSenderBuild.sol#L63) is not in mixedCase

src/bridge/modules/wrapper/CCIPSenderBuild.sol#L63


 - [ ] ID-37
Parameter [CCIPBaseSender.transferTokens(uint64,address,address,uint256,uint256)._receiver](src/bridge/CCIPBaseSender.sol#L43) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L43


 - [ ] ID-38
Parameter [CCIPBaseSender.buildEndSend(uint64,address,uint256,Client.EVMTokenAmount[])._paymentMethodId](src/bridge/CCIPBaseSender.sol#L112) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L112


 - [ ] ID-39
Parameter [CCIPBaseSender.transferTokens(uint64,address,address,uint256,uint256)._amount](src/bridge/CCIPBaseSender.sol#L45) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L45


 - [ ] ID-40
Parameter [CCIPBaseSender.transferTokensBatch(uint64,address,address[],uint256[],uint256)._destinationChainSelector](src/bridge/CCIPBaseSender.sol#L80) is not in mixedCase

src/bridge/CCIPBaseSender.sol#L80


 - [ ] ID-41
Parameter [CCIPAllowlistedChain.setAllowlistChain(uint64,bool,bool)._chainSelector](src/bridge/modules/configuration/CCIPAllowlistedChain.sol#L39) is not in mixedCase

src/bridge/modules/configuration/CCIPAllowlistedChain.sol#L39

