// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {Base721Token} from "../src/Base721Token.sol";
import {Base20Token} from "../src/Base20Token.sol";
import {SigUtils} from "./utils/SigUtils.sol";

contract NFTMarketTest is Test {
    Base721Token nft;
    Base20Token usdt;
    NFTMarket market;
    SigUtils internal sigUtils;

    // 721 Owner
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    address tom = makeAddr("tom");

    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(alice);
        market = new NFTMarket();
        nft = new Base721Token("AA", "A", "");
        nft.setNFTMartket(address(market));
        usdt = new Base20Token("Teg", "USDT", 1e18);
        sigUtils = new SigUtils(
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("Base721Token")),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(market)
                )
            )
        );

        //变更msg.sender
        // nft.mint(alice, 1); //此行将以alice的身份执行
    }
    function test_buyPermit() public {
        uint256 tokenId = 1;
        buyPermit(tokenId);
    }
    function buyPermit(uint256 tokenId) private {
        vm.startPrank(tom);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: nft.owner(),
            spender: address(tom),
            value: tokenId,
            nonce: tokenId,
            deadline: 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        // console.log("==============================");
        // console.logBytes32(digest);
        // console.log(nft.owner());
        // console.log(msg.sender);
        // console.log(tokenId);
        // console.log(1 days);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        market.permitBuy(address(nft), tokenId, 1 days, v, r, s);
        assertEq(nft.ownerOf(tokenId), address(tom), "token transfer faild");
    }
}
