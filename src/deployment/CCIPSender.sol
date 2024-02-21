// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//import "../bridge/BridgeVault.sol";
import "../bridge/modules/CCIP/modules/CCIPBaseSender.sol";
import "../bridge/modules/CCIP/modules/CCIPBaseReceiver.sol";

contract CCIPSender is CCIPBaseReceiver,CCIPBaseSender  {
    // Custom errors to provide more descriptive revert messages.

    // CCIPBaseSender(_link) 
     constructor(address admin, address _router, address /*_link*/) CCIPRouterManage(_router) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
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

    /**
    * @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token, use for example, to pay the gas fee
    * @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    * @param _beneficiary The address to which the tokens will be sent.
    * @param _token The contract address of the ERC20 token to be withdrawn.
    */
    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        
        if (amount == 0) {
            revert CCIPErrors.NothingToWithdraw();
        }
        // Check return value ?
        IERC20(_token).transfer(_beneficiary, amount);
    }

    function supportsInterface(bytes4 interfaceId) public virtual pure override( AuthorizationModule, CCIPBaseReceiver) 
    returns (bool){
        return (  CCIPBaseReceiver.supportsInterface(interfaceId) || AuthorizationModule.supportsInterface(interfaceId));
    
    }
}