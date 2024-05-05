// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IBase20Implementation {
    function initialize(
        string calldata _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price
    ) external;
}
