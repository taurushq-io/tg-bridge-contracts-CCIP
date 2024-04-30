# CHANGELOG

Please follow <https://changelog.md/> conventions.



## 1.1.0 - 20240430

- In the version 1.0.0, when fees are paid in native tokens, the function `ccipSend` from the CCIP router was called without the `value`argument.

**Old version**

```solidity
// Send CCIP Message
messageId = router.ccipSend(_destinationChainSelector, message); 
```

**new version**

```solidity
if(_paymentMethodId == 0){ // Native token
	messageId = router.ccipSend{value: fees}(_destinationChainSelector, message); 
} else{
    messageId = router.ccipSend(_destinationChainSelector, message); 
}
```

Tests have been improved to catch this bug.

- Chainlink has released a library ([Chainlink local](https://github.com/smartcontractkit/chainlink-local/tree/main)) to test Chainlink CCIP locally. This version includes a test using this simulator where fees are paid in native tokens.

- This version adds also:

  - A public function ` getFee` in order to know the fees from the router
  - A function `setMessageData`to set the data inside the message if in the future, there is a change in the CCIP bridge. Current default value is an empty string
  - Rename the function `setGasLimit` in `setMessageGasLimit` to clearly indicate that it is the gas limit put in the message for CCIP.

  

## 1.0.0 - 20240423

- 🎉 First release !
