// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface INFTMarket {
    event listOrder(
        address indexed from,
        address indexed contractAddress,
        uint256 indexed tokenId,
        uint256 listPrice
    );
    event buyOrder(
        address indexed from,
        address indexed contractAddress,
        uint256 indexed tokenId,
        uint256 listPrice
    );

    function list(
        address contractAddress,
        uint256 tokenId,
        uint256 listPric
    ) external;

    function buyNFT(
        address contractAddress,
        uint256 tokenId,
        address payErc20Contract
    ) external;
    function listPrice(
        address contractAddress,
        uint256 tokenId
    ) external returns (uint256);

    function ownerOf(
        address contractAddress,
        uint256 tokenId
    ) external view returns (address);
}
