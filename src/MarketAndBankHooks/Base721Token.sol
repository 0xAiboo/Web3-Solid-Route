// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Base721Token is ERC721 {
    string private baseUrl;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory url_
    ) ERC721(name_, symbol_) {
        baseUrl = url_;
    }

    function mint(address _to, uint256 tokenId) public {
        _mint(_to, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUrl;
    }
}
