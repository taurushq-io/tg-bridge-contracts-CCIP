// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
import "./ERC20WrapperInterface.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
/**
 * @title myTokenTest
 * @dev ERC20 for testing
 */
contract ERC20Wrapper is ERC20, IERC20WrapperInterface, AccessControl {
    uint8 private _decimals;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    /**
     * @dev Give the initial supply to the sender
     */
    constructor(
        address owner,
        string memory name,
        string memory symbol,
        uint8 decimals_,
        address bridge
    ) ERC20(name, symbol)  {
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(MINTER_ROLE, bridge);
        _decimals =  decimals_;
    }

     /**
     * @notice  Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
     * @dev
     * See {OpenZeppelin ERC20-_mint}.
     *
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * - The caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value) onlyRole(MINTER_ROLE) public{
        _mint(account, value);
    }

    /**
     * @notice Destroys a `value` amount of tokens from `account`, by transferring it to address(0).
     * @dev
     * See {ERC20-_burn}
     *
     * Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
     * Requirements:
     * - the caller must have the `MINTER_ROLE`.
     */
    function burn(address account, uint256 value) onlyRole(MINTER_ROLE) public{
        _burn(account, value);
    }


    /**
     *
     * @notice Returns the number of decimals used to get its user representation.
     * @inheritdoc ERC20
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}