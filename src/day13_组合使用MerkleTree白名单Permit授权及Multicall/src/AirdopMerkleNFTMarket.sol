// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { console} from "forge-std/Test.sol";

contract AirdopMerkleNFTMarket {
    bytes32 public immutable merkleRoot;
    mapping(address => bool) whiteList;
    struct listUser {
        address owner;
        uint256 listPrice;
    }
    mapping(address => mapping(uint256 => listUser)) private marketList;
    ERC721 nft;
    ERC20Permit token;
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
    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }
    function permitPrePay(
        address token_ca,
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        ERC20Permit(token_ca).permit(owner, spender, value, deadline, v, r, s);
    }
    function claimNFT(
        address _buyer,
        address _nft_ca,
        uint256 _tokenId,
        address _token_ca,
        bytes32[] calldata proof
    ) public {
        uint256 amount = listPriceOf(_nft_ca, _tokenId);
        address owner = nftOwnerOf(_nft_ca, _tokenId);
        if (_isWhite(proof)) {
            amount = (amount * 50) / 100;
        }
        ERC20Permit(_token_ca).transferFrom(_buyer, owner, amount);
        ERC721(_nft_ca).safeTransferFrom(address(this), _buyer, _tokenId);
        emit listOrder(msg.sender, _nft_ca, _tokenId, amount);
    }
    function multiCall(bytes[] calldata data) public {
        for (uint i = 0; i < data.length; i++) {
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Delegatecall failed");
        }
    }
    function listPriceOf(
        address _nft_ca,
        uint256 _tokenId
    ) public view returns (uint256) {
        return marketList[_nft_ca][_tokenId].listPrice;
    }
    function nftOwnerOf(
        address _nft_ca,
        uint256 _tokenId
    ) public view returns (address) {
        return marketList[_nft_ca][_tokenId].owner;
    }
    function list(address nft_ca, uint256 tokenId, uint256 listPric) public {
        nft = ERC721(nft_ca);
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        marketList[nft_ca][tokenId].owner = msg.sender;
        marketList[nft_ca][tokenId].listPrice = listPric;
        emit listOrder(msg.sender, nft_ca, tokenId, listPric);
    }
    function _isWhite(bytes32[] calldata proof) internal view returns (bool) {
        // require(!whiteList[msg.sender], "mint is already");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        // require(verifyLeaf(proof, leaf));
        // whiteList[msg.sender] = true;
        return verifyLeaf(proof, leaf);
    }
    // Function to verify the proof of a leaf against the stored merkle root
    function verifyLeaf(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRoot, leaf);
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
