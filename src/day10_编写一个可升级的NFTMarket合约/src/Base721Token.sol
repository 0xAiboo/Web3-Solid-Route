// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import {console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract Base721Token is ERC721, Ownable {
    string private baseUrl;
    uint256 private tokenId = 1;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory url_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        baseUrl = url_;
    }

    function mint(address _to) external {
        _mint(_to, tokenId++);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUrl;
    }
}
