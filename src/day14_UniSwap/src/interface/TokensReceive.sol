// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface TokensReceive {
    function tokensReceive(
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data
    ) external returns (bool);
}
