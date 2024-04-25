// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
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

    function list(
        address contractAddress,
        uint256 tokenId,
        uint256 listPric
    ) public {
        NFTContract = Base721Token(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenId);
        marketList[contractAddress][tokenId].owner = msg.sender;
        marketList[contractAddress][tokenId].listPrice = listPric;
    }

    function buyNFT(
        address contractAddress,
        uint256 tokenId,
        address payErc20Contract
    ) public {
        tokenContract = Base20Token(payErc20Contract);
        require(
            tokenContract.transferFrom(
                msg.sender,
                marketList[contractAddress][tokenId].owner,
                marketList[contractAddress][tokenId].listPrice
            ),
            "Money Transfer fail"
        );
        // NFTContract.safeTransferFrom(address(this), msg.sender, tokenId);
        // marketList[contractAddress][tokenId].owner = address(0);
        // marketList[contractAddress][tokenId].listPrice = 0;
        _transfer(address(this), contractAddress, tokenId, msg.sender);
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
        tokenContract.transfer(
            owner,
            _value
        );

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
