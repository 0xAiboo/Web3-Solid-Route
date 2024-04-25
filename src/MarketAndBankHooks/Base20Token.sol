// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// import "@openzeppelin/contracts/utils/Address.sol";
import "./library/Address.sol";
import "./interface/TokensReceive.sol";

contract Base20Token is ERC20 {
    using Address for address;

    // TokensReceive transferBack;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, totalSupply);
    }

    function _checkOnTokensReceived(address _to, bytes memory _data) private {}

    function transferWithCallback(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public {
        transfer(_to, _value);
        if (_to.isContract())
            TokensReceive(_to).tokensReceive(msg.sender, _to, _value, _data);
    }
}
