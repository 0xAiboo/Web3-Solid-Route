// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Base20Token.sol";
import "./Base721Token.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interface/TokensReceive.sol";

contract NFTMarket is TokensReceive {
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

    function bytesToStruct(bytes memory data)
        private
        pure
        returns (BuyNft memory, bool)
    {
        BuyNft memory myStruct;
        bool success = false;

        // Ensure the byte array has the correct length
        if (data.length == 32) {
            // Convert the first 32 bytes to uint256
            assembly {
                mstore(add(myStruct, 32), mload(add(data, 32)))
            }
            // Convert the next 32 bytes to bool
            assembly {
                mstore(add(myStruct, 64), mload(add(data, 64)))
            }
            success = true;
        }

        return (myStruct, success);
    }

    function list(
        address contractAddress,
        uint256 tokenId,
        uint256 listPrice
    ) public {
        NFTContract = Base721Token(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenId);
        marketList[contractAddress][tokenId].owner = msg.sender;
        marketList[contractAddress][tokenId].listPrice = listPrice;
    }

    function buyNFT(
        address contractAddress,
        uint256 tokenId,
        address payErc20Contract
    ) public {
        tokenContract = Base20Token(payErc20Contract);
        // NFTContract = Base721Token(contractAddress);
        uint256 price = marketList[contractAddress][tokenId].listPrice;

        require(
            tokenContract.transferFrom(
                msg.sender,
                marketList[contractAddress][tokenId].owner,
                marketList[contractAddress][tokenId].listPrice
            ),
            "Token Transfer fail"
        );
        // NFTContract.safeTransferFrom(address(this), msg.sender, tokenId);
        // marketList[contractAddress][tokenId].owner = address(0);
        // marketList[contractAddress][tokenId].listPrice = 0;
        _transfer(address(this), contractAddress, tokenId, msg.sender);
    }

    function listPrice(address contractAddress, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return marketList[contractAddress][tokenId].listPrice;
    }

    function ownerOf(address contractAddress, uint256 tokenId)
        public
        view
        returns (address)
    {
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
        require(ownerOf(contractAddress, tokenId) == from, "user is not owner");
        NFTContract = Base721Token(contractAddress);
        NFTContract.safeTransferFrom(address(this), _to, tokenId);
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
        (BuyNft memory buyNft, bool success) = bytesToStruct(_data);
        require(success, "data entry errors");
        require(listPrice(buyNft.nftAdrees, buyNft.nftTokenId) == _value, "No equals list price");
        bool transferSuccess = _transfer(
            _to,
            buyNft.nftAdrees,
            buyNft.nftTokenId,
            _from
        );
        require(transferSuccess, "tansfer fail");
        return transferSuccess;
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
