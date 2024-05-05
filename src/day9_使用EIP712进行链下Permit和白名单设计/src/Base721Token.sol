// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import {console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract Base721Token is ERC721, Ownable, EIP712 {
    string private baseUrl;
    uint256 private tokenId = 1;
    address private NFTMarketAddress;
    error onlyNFTMarket(address account);
    error ExpiredSignature(uint256 deadline);
    error InvalidSigner(address signer, address owner);
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    constructor(
        string memory name_,
        string memory symbol_,
        string memory url_
    ) ERC721(name_, symbol_) Ownable(msg.sender) EIP712(name_, "1") {
        baseUrl = url_;
    }
    modifier onlyMarket() {
        _checkMarket();
        _;
    }
    function setNFTMartket(address nftMarketAddress) public {
        NFTMarketAddress = nftMarketAddress;
    }
    function _checkMarket() internal view {
        if (NFTMarketAddress != msg.sender) {
            revert onlyNFTMarket(msg.sender);
        }
    }
    function mint(address _to) external {
        _mint(_to, tokenId++);
    }
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
    function _baseURI() internal view override returns (string memory) {
        return baseUrl;
    }
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ExpiredSignature(deadline);
        }
        bytes32 structHash = keccak256(
            abi.encode(_PERMIT_TYPEHASH, owner, spender, value, value, deadline)
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert InvalidSigner(signer, owner);
        }
      
        _approve(spender, value, owner);
    }
    // function signAddress(
    //     address userAddress
    // ) public view onlyOwner returns (bytes32) {
    //     bytes32 hashStruct = keccak256(
    //         abi.encode(owner(), userAddress, address(this), tokenId)
    //     );
    //     return hashStruct;
    // }
}
