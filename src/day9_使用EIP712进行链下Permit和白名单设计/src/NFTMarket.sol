// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import {console} from "forge-std/Test.sol";
import "./Base20Token.sol";
import "./Base721Token.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interface/TokensReceive.sol";
import "./interface/INFTMarket.sol";
contract NFTMarket is TokensReceive, INFTMarket {
    Base20Token tokenContract;
    Base721Token NFTContract;

    struct BuyNft {
        address nftAdrees;
        uint256 nftTokenId;
    }
    struct listUser {
        address owner;
        uint256 listPrice;
    }
    mapping(address => mapping(uint256 => listUser)) private marketList;
    function list(
        address contractAddress,
        uint256 tokenId,
        uint256 listPric
    ) public {
        NFTContract = Base721Token(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenId);
        marketList[contractAddress][tokenId].owner = msg.sender;
        marketList[contractAddress][tokenId].listPrice = listPric;
        emit listOrder(msg.sender, contractAddress, tokenId, listPric);
    }

    function buyNFT(
        address contractAddress,
        uint256 tokenId,
        address payErc20Contract
    ) public {
        uint256 buyPrice = listPrice(contractAddress, tokenId);
        tokenContract = Base20Token(payErc20Contract);
        require(
            tokenContract.transferFrom(
                msg.sender,
                marketList[contractAddress][tokenId].owner,
                buyPrice
            ),
            "Money Transfer fail"
        );
        // NFTContract.safeTransferFrom(address(this), msg.sender, tokenId);
        // marketList[contractAddress][tokenId].owner = address(0);
        // marketList[contractAddress][tokenId].listPrice = 0;
        _transfer(address(this), contractAddress, tokenId, msg.sender);
        emit buyOrder(msg.sender, contractAddress, tokenId, buyPrice);
    }

    function listPrice(
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {
        return marketList[contractAddress][tokenId].listPrice;
    }

    function ownerOf(
        address contractAddress,
        uint256 tokenId
    ) public view returns (address) {
        return marketList[contractAddress][tokenId].owner;
    }

    function _transfer(
        address from,
        address contractAddress,
        uint256 tokenId,
        address _to
    ) private returns (bool) {
        require(
            ownerOf(contractAddress, tokenId) != address(0),
            "user is not list"
        );
        require(
            ownerOf(contractAddress, tokenId) != _to,
            "buyer is not seller"
        );
        NFTContract = Base721Token(contractAddress);
        NFTContract.safeTransferFrom(from, _to, tokenId);
        marketList[contractAddress][tokenId].owner = address(0);
        marketList[contractAddress][tokenId].listPrice = 0;
        return true;
    }

    function tokensReceive(
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data
    ) external returns (bool) {
        BuyNft memory buyNftData = abi.decode(_data, (BuyNft));

        require(
            buyNftData.nftAdrees != address(0) && buyNftData.nftTokenId > 0,
            "data entry errors"
        );

        require(
            listPrice(buyNftData.nftAdrees, buyNftData.nftTokenId) == _value,
            "No equals list price"
        );
        address owner = ownerOf(buyNftData.nftAdrees, buyNftData.nftTokenId);

        // require(1 != 1, buyNftData.nftAdrees);
        bool transferSuccess = _transfer(
            _to,
            buyNftData.nftAdrees,
            buyNftData.nftTokenId,
            _from
        );
        require(transferSuccess, "tansfer fail");
        tokenContract = Base20Token(msg.sender);
        tokenContract.transfer(owner, _value);

        return transferSuccess;
    }
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );

    function permitBuy(
        address contractAddress,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _permitBuy(contractAddress, tokenId, deadline, v, r, s);
    }
    function _permitBuy(
        address contractAddress,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Base721Token")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );

        // console.log("some explanation: %s", eip712DomainHash);
        // return eip712DomainHash;
        NFTContract = Base721Token(contractAddress);
        address owner = NFTContract.owner();
        bytes32 hashStruct = keccak256(
            abi.encode(
                keccak256(
                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                ),
                owner,
                msg.sender,
                tokenId,
                tokenId,
                deadline
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );
        // console.log("=============market=================");
        // console.logBytes32(hash);
        // console.log(owner);
        // console.log(msg.sender);
        // console.log(tokenId);
        // console.log(deadline);
        // console.log("==============================");
        address signer = ecrecover(hash, v, r, s);

        require(signer == owner, "MyFunction: invalid signature");
        require(signer != address(0), "ECDSA: invalid signature");

        require(
            block.timestamp < deadline,
            "MyFunction: signed transaction expired"
        );
        NFTContract.mint(msg.sender);
    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
