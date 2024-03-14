// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../bridge/CCIPBaseSender.sol";
import "../bridge/modules/wrapper/CCIPWithdraw.sol";
import "openzeppelin-contracts/metatx/ERC2771Context.sol";
contract CCIPSender is CCIPBaseSender, CCIPWithdraw  {

    /**
    * @param admin Address of the contract (Access Control)
    * @param _router 
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */forwarderIrrevocable
    constructor(address admin, address routerIrrevocable, address forwarderIrrevocable) CCIPRouterManage(_router) ERC2771Context(forwarderIrrevocable)
    {
        if(iszero(admin)){
            revert CCIP_ADMIN_ADDRESS_ZERO_NOT_ALLOWED();
        }
        if(iszero(routerIrrevocable)){
            revert CCIP_ROUTER_ADDRESS_ZERO_NOT_ALLOWED();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTx
    */
    function _msgSender()
        internal
        view
        override(ERC2771Context, Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTx
    */
    function _msgData()
        internal
        view
        override(ERC2771Context, Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTx
    */
    function _contextSuffixLength() internal view 
    override(ERC2771Context, Context)
    returns (uint256) {
         return ERC2771Context._contextSuffixLength();
    }

}