// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";


abstract contract AuthorizationModule is AccessControl{
    // MintModule
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    // PauseModule
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

   
    /*
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControl) returns (bool) {
        // The Default Admin has all roles
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControl.hasRole(role, account);
    }

    function supportsInterface(bytes4 interfaceId) public pure virtual override(AccessControl) 
    returns (bool){
         return interfaceId == type(IAccessControl).interfaceId;
    
    }

    uint256[50] private __gap;
}