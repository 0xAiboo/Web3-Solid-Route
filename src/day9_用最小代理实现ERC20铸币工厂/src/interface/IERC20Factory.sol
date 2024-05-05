// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IERC20Factory {
    event setERC20ImplementationEvent(address indexed implementationAddress);
    event setRatioEvent(uint256 indexed ratio);

    function setErc20Implementation(address implementationAddress) external;
    function setRatio(uint256 ratio) external;

    function deployInscription(
        string calldata symbol,
        uint totalSupply,
        uint perMint,
        uint price
    ) external returns (address);
    function mintInscription(address tokenAddr) external payable;
}
