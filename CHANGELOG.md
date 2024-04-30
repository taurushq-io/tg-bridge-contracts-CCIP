# CHANGELOG

Please follow <https://changelog.md/> conventions.



## 1.0.1 - 20240429

In the version 1.0.0, when fees are paid in native tokens, the function ccipSend from the CCIP router was called without the `value`argument.

Old version

**new version**

```solidity
if(_paymentMethodId == 0){ // Native token
messageId = router.ccipSend{value: fees}(_destinationChainSelector, message); 
} else{
        messageId = router.ccipSend(_destinationChainSelector, message); 
}
```



## 1.0.0 - 20240423

- 🎉 First release !
