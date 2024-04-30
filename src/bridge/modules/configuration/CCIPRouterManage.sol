// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IRouterClient} from "ccip/interfaces/IRouterClient.sol";
import {Client} from "ccip/libraries/Client.sol";
import "../libraries/CCIPErrors.sol";

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract CCIPRouterManage  {
  address internal immutable i_router;

  constructor(address router) {
    if (router == address(0)){
        revert CCIPErrors.CCIP_Router_Address_Zero_Not_Allowed();
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

    function getFee(uint64 _destinationChainSelector, Client.EVM2AnyMessage memory message ) public view returns(uint256){
        // external call
        uint256 fees = IRouterClient(i_router).getFee(_destinationChainSelector, message);
        return fees;
    }

  /// @dev only calls from the set router are accepted.
  /// Only useful with a receiver contract
  modifier onlyRouter() {
    if (msg.sender != address(i_router)){
      revert CCIPErrors.CCIP_Router_InvalidRouter(msg.sender);
    } 
    _;
  }
}
