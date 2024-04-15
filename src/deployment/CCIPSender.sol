// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../bridge/CCIPBaseSender.sol";
import "../bridge/modules/wrapper/CCIPWithdraw.sol";
import "openzeppelin-contracts/metatx/ERC2771Context.sol";
contract CCIPSender is CCIPBaseSender, CCIPWithdraw, ERC2771Context  {

    /**
    * @param admin Address of the contract (Access Control)
    * @param routerIrrevocable CCIP router
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(address admin, address routerIrrevocable, address forwarderIrrevocable) CCIPRouterManage(routerIrrevocable) ERC2771Context(forwarderIrrevocable)
    {
        if(address(admin) == address(0)){
            revert CCIPErrors.CCIP_Admin_Address_Zero_Not_Allowed();
        }
        // Don't check router address since it is done in CCIPRouterManage
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