// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ESNBToken is ERC20Permit {
    string private constant _name = "ESNBToken";
    string private constant _symbol = "ESNBT";
    uint256 private constant _total = 21_000_000 * 1e18;
    constructor() ERC20Permit(_name) ERC20(_name, _symbol) {
        // _mint(msg.sender, _total);
    }

    // function public mint
}
