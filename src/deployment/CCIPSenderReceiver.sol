// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../bridge/CCIPBaseSender.sol";
import "../bridge/CCIPBaseReceiver.sol";
import "../bridge/modules/wrapper/CCIPContractBalance.sol";
contract CCIPSenderReceiver is CCIPBaseReceiver,CCIPBaseSender, CCIPContractBalance  {
     constructor(address admin, address _router) CCIPRouterManage(_router) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function supportsInterface(bytes4 interfaceId) public virtual pure override( AuthorizationModule, CCIPBaseReceiver) 
    returns (bool){
        return (  CCIPBaseReceiver.supportsInterface(interfaceId) || AuthorizationModule.supportsInterface(interfaceId));
    
    }
}