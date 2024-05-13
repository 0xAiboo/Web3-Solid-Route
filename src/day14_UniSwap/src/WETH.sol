// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WETH is ERC20Permit {
    string private constant _name = "WETH";
    string private constant _symbol = "WETH";
    uint256 private constant _total = 21_000_000 * 1e18;
    constructor() ERC20Permit(_name) ERC20(_name, _symbol) {
        _mint(msg.sender, _total);
    }
}
