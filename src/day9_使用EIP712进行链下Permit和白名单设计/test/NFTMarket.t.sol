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
    struct SignModal {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    // 721 Owner
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);

    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(alice);
        market = new NFTMarket();
        nft = new Base721Token("AA", "A", "");
        nft.setNFTMartket(address(market));
        usdt = new Base20Token("Teg", "USDT", 1e18);
        usdt.transfer(tom, 1e18);

        //变更msg.sender
        nft.mint(alice); //此行将以alice的身份执行
    }

    function test_listPermit() public {
        address contractAddress = address(nft);
        uint256 tokenId = 1;
        uint256 price = 1000;
        listPermit(contractAddress, tokenId, price);
    }
    function listPermit(
        address contractAddress,
        uint256 tokenId,
        uint256 price
    ) public {
        sigUtils = new SigUtils(nft.DOMAIN_SEPARATOR());

        vm.startPrank(alice);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(alice),
            spender: address(market),
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
        market.permitList(contractAddress, price, tokenId, 1 days, v, r, s);
        assertEq(
            market.listPrice(contractAddress, tokenId),
            price,
            "permit list failed"
        );
        assertEq(
            market.ownerOf(contractAddress, tokenId),
            address(alice),
            "permit list failed"
        );
        assertEq(nft.ownerOf(tokenId), address(market), "permit list failed");

        // market.listPrice(tokenId);
    }
    function test_buyPermit() public {
        address contractAddress = address(nft);
        uint256 tokenId = 1;
        uint256 price = 1000;
        listPermit(contractAddress, tokenId, price);
        buyPermit(tokenId, price);
    }
    function buyPermit(uint256 tokenId, uint256 price) public {
        //白名单验证通过
        // whiteSign(tokenId);
        buySign(tokenId, price);
    }

    function whiteSign(
        uint256 tokenId
    ) public returns (uint8 v1, bytes32 r1, bytes32 s1) {
        sigUtils = new SigUtils(nft.DOMAIN_SEPARATOR());

        vm.startPrank(tom);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: nft.owner(),
            spender: address(tom),
            value: tokenId,
            nonce: tokenId,
            deadline: 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        return (v, r, s);
        // market.isWhite(address(nft), tokenId, 1 days, v, r, s);
        // assertEq(nft.ownerOf(tokenId), address(tom), "You dont in whiteList");
    }

    function buySign(uint256 tokenId, uint256 _value) public {
        (uint8 v1, bytes32 r1, bytes32 s1) = whiteSign(tokenId);
        console.log(v1);
        console.logBytes32(r1);
        console.logBytes32(s1);
        NFTMarket.SignModal memory sign1 = NFTMarket.SignModal(v1, r1, s1);
        sigUtils = new SigUtils(usdt.DOMAIN_SEPARATOR());

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: tom,
            spender: address(market),
            value: _value,
            nonce: usdt.nonces(tom),
            deadline: 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPrivateKey, digest);
        NFTMarket.SignModal memory sign2 = NFTMarket.SignModal(v, r, s);

        uint256 tomBalance = usdt.balanceOf(tom);
        uint256 aliceBalance = usdt.balanceOf(alice);
        vm.startPrank(tom);
        market.permitBuy(
            address(nft),
            tokenId,
            address(usdt),
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            sign2,
            sign1
        );
        assertEq(nft.ownerOf(tokenId), address(tom), "buy failed");
        assertEq(
            usdt.balanceOf(address(tom)),
            tomBalance - _value,
            "buy failed"
        );
        assertEq(
            usdt.balanceOf(address(alice)),
            aliceBalance + _value,
            "buy failed"
        );
    }
}
