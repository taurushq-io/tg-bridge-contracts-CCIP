// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IRouterClient} from "ccip/interfaces/IRouterClient.sol";

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract CCIPRouterManage  {
  address internal immutable i_router;
  error InvalidRouter(address router);

  constructor(address router) {
    if (router == address(0)){
        revert InvalidRouter(address(0));
    } 
    i_router = router;
  }

  /// @notice Return the current router
  /// @return i_router address
  function getRouter() public view returns (address) {
    return address(i_router);
  }

    /**
    * @param chainSelector blockchain selector
    * @return tokens list of contract address for all supported tokens
    */
    function getSupportedTokens(
        uint64 chainSelector
    ) external view returns (address[] memory tokens) {
        tokens = IRouterClient(i_router).getSupportedTokens(chainSelector);
    }

  /// @dev only calls from the set router are accepted.
  modifier onlyRouter() {
    if (msg.sender != address(i_router)){
      revert InvalidRouter(msg.sender);
    } 
    _;
  }
}
