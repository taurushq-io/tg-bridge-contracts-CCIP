// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20WrapperInterface {
    function mint(address to, uint amount) external;
    function burn(address from, uint amount) external;
}