// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Base20Token.sol";
import "./Base721Token.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract NFTMarketV1 is EIP712 {
    ERC20 tokenContract;
    ERC721 NFTContract;
    struct listUser {
        address owner;
        uint256 listPrice;
    }
    mapping(address => mapping(uint256 => listUser)) private marketList;
    string private constant name = "NFTMarket";
    constructor() EIP712(name, "1") {}
    function list(
        address contractAddress,
        uint256 tokenId,
        uint256 listPrice
    ) public {
        // (bool success, bytes memory approveBytest) = contractAddress.call(
        //     abi.encodeWithSignature(
        //         "_isApprovedOrOwner(uint256)",
        //         address(this),
        //         tokenId
        //     )
        // );
        // bool isApprove = abi.decode(approveBytest, (bool));
        // require(isApprove, "Please authorize first");

        // (bool transferSuccess, ) = contractAddress.call(
        //     abi.encodeWithSignature(
        //         "safeTransferFrom(address,address,uint)",
        //         msg.sender,
        //         address(this),
        //         tokenId
        //     )
        // );
        NFTContract = ERC721(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenId);
        // if (transferSuccess) {
        marketList[contractAddress][tokenId].owner = msg.sender;
        marketList[contractAddress][tokenId].listPrice = listPrice;
        // return true;
        // }
        // return false;
    }

    function buyNFT(
        address contractAddress,
        uint256 tokenId,
        address payErc20Contract
    ) public {
        tokenContract = ERC20(payErc20Contract);
        NFTContract = ERC721(contractAddress);
        uint256 price = marketList[contractAddress][tokenId].listPrice;
        require(
            tokenContract.allowance(msg.sender, address(this)) >= price,
            "Insufficient authorization limit"
        );
        require(
            tokenContract.balanceOf(msg.sender) >= price,
            "Insufficient balance"
        );
        require(
            tokenContract.transferFrom(
                msg.sender,
                marketList[contractAddress][tokenId].owner,
                marketList[contractAddress][tokenId].listPrice
            ),
            "Token Transfer fail"
        );
        NFTContract.safeTransferFrom(address(this), msg.sender, tokenId);
        marketList[contractAddress][tokenId].owner = address(0);
        marketList[contractAddress][tokenId].listPrice = 0;
    }

    function queryPrice(
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {
        return marketList[contractAddress][tokenId].listPrice;
    }

    function queryOwner(
        address contractAddress,
        uint256 tokenId
    ) public view returns (address) {
        return marketList[contractAddress][tokenId].owner;
    }

    function onERC721BuyReceived(
        address contractAddress,
        address buyUser,
        uint256 tokenId,
        bytes calldata
    ) external returns (bool) {
        NFTContract = ERC721(contractAddress);
        NFTContract.safeTransferFrom(address(this), buyUser, tokenId);
        marketList[contractAddress][tokenId].owner = address(0);
        marketList[contractAddress][tokenId].listPrice = 0;
        return true;
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
