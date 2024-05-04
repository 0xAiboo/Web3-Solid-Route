// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Base721Token is ERC721, Ownable {
    string private baseUrl;
    uint256 private tokenId = 1;
    address private NFTMarketAddress;
    error onlyNFTMarket(address account);
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );
    constructor(
        string memory name_,
        string memory symbol_,
        string memory url_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
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
    function mint(address _to) public onlyMarket {
        _mint(_to, tokenId++);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUrl;
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
