// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {AirdopMerkleNFTMarket} from "../src/AirdopMerkleNFTMarket.sol";
import {NBNFT} from "../src/NBNFT.sol";
import {NBToken} from "../src/NBToken.sol";
import {SigUtils} from "./utils/SigUtils.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
contract MerkleTreeTest is Test {
    using Strings for uint256;
    SigUtils internal sigUtils;

    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);

    uint256 bobPrivate =
        0xfd879cbfef94d2006a142ea2b25e44218fdd1844684c0dcfb9050eb39d494302;
    address bob = vm.addr(bobPrivate);
    address owner = makeAddr("owner");
    bytes32 root =
        0x26f2b59d8dbccdb32765160ecf5e15362478352777d6e1681592386f82cb7e4c;
    bytes32[] leafs = [
        bytes32(
            0x57006d605a4fd84fc971f425cdc2fdc69c7d0c5c3e35af9ea2fc661b68bec923
        ),
        bytes32(
            0x0d47c1bfe4f0b40211e363c95e270dcebf35263644573fb97cc84be93008a676
        ),
        bytes32(
            0x45bca28a61afae4d4a1daf3d256d500d6a7946e4b0bc827366bcd91b2bfbcc03
        ),
        bytes32(
            0x1639245e0b26561ad279462c96fc682aba84574b248f86434ac426029259855f
        )
    ];
    AirdopMerkleNFTMarket mk;
    NBToken token;
    NBNFT nft;
    function setUp() public {
        vm.startPrank(alice);
        mk = new AirdopMerkleNFTMarket(root);
        token = new NBToken();
        nft = new NBNFT("AA", "a", "");
        nft.mint(address(alice));
        nft.approve(address(mk), 1);
        token.transfer(bob, 1000000 * 1e18);

        mk.list(address(nft), 1, 100 * 1e18);
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());
        vm.stopPrank();
    }
    function test_buy() public {
        vm.startPrank(bob);

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: bob,
            spender: address(mk),
            value: 100 * 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPrivate, digest);
        vm.startPrank(owner);

        bytes memory call1 = abi.encodeWithSignature(
            "permitPrePay(address,address,address,uint256,uint256,uint256,uint8,bytes32,bytes32)",
            address(token),
            permit.owner,
            permit.spender,
            permit.value,
            permit.nonce,
            permit.deadline,
            v,
            r,
            s
        );

        bytes memory call2 = abi.encodeWithSignature(
            "claimNFT(address,address,uint256,address,bytes32[])",
            address(bob),
            address(nft),
            1,
            address(token),
            leafs
        );
        bytes[] memory data = new bytes[](2);
        data[0] = call1;
        data[1] = call2;
        mk.multiCall(data);

        vm.stopPrank();
    }

    function testFuzz_SetNumber(uint256 x) public {}
}
