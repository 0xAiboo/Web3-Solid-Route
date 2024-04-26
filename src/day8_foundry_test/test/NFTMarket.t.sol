// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {Base721Token} from "../src/Base721Token.sol";
import {Base20Token} from "../src/Base20Token.sol";
contract NFTMarketTest is Test {
    Base721Token nft;
    Base20Token usdt;
    NFTMarket market;
    address alice = makeAddr("alice");
    address tom = makeAddr("tom");
  
    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(alice);
        market = new NFTMarket();
        nft = new Base721Token("AA", "A", "");
        usdt = new Base20Token("Teg", "USDT", 1e18);
        //变更msg.sender
        nft.mint(alice, 1); //此行将以alice的身份执行
    }
    function test_listNFT() public {
        uint256 tokenId = 1;
        uint256 price = 1000;
        listNFT(tokenId, price);
    }
    function listNFT(uint256 tokenId, uint256 price) private {
        vm.startPrank(alice);

        /**
         *  预期错误：没有授权
         */
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InsufficientApproval(address,uint256)",
                address(market),
                tokenId
            )
        );
        market.list(address(nft), tokenId, price);

        /**
         *  预期错误：没有MintToken
         */
        vm.expectRevert(
            abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 999)
        );
        market.list(address(nft), 999, price);

        nft.approve(address(market), tokenId);
        market.list(address(nft), tokenId, price);
        //查询挂单价格是否正确
        assertEq(
            market.listPrice(address(nft), tokenId),
            price,
            "expect listPrice error"
        );
        //查询挂单用户是否正确
        assertEq(
            market.ownerOf(address(nft), tokenId),
            alice,
            "expect listPrice error"
        );
        vm.stopPrank();
    }

    function test_buyNFT() public {
        uint256 tokenId = 1;
        uint256 price = 1000;
        listNFT(tokenId, price);
        buyNFT(tokenId, price);
    }
    struct BuyNft {
        address nftAdrees;
        uint256 nftTokenId;
    }
    function test_buyNFTCallBack() public {
        uint256 tokenId = 1;
        uint256 price = 1000;
        listNFT(tokenId, price);
        buyNFTCallback(tokenId, price);
    }
    function buyNFTCallback(uint256 tokenId, uint256 price) private {
        BuyNft memory buyData = BuyNft(address(nft), tokenId);
        vm.startPrank(alice);

        /**
         *
         *  预期错误：价格不等于挂单价格
         *
         */
        vm.expectRevert("No equals list price");
        usdt.transferWithCallback(address(market), 100, abi.encode(buyData));

        /**
         *!!!!!!!!!!!!!!!!!!!!!!!!!!
         *  预期错误：参数错误
         *
         */
        // vm.expectRevert("call reverted as expected, but without data");
        // usdt.transferWithCallback(address(market), 100, "0x3078656a697177656a696f31236a656a716f77656f717769696f71696f6f696f693233696f313233696f316f693233");
        /**
         * 预期错误：buyer is not seller
         *
         */
        vm.expectRevert("buyer is not seller");
        usdt.transferWithCallback(address(market), price, abi.encode(buyData));

        /**
         * 预期错误：余额不足
         *
         */
        vm.startPrank(tom);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientBalance(address,uint256,uint256)",
                address(tom),
                0,
                price
            )
        );
        usdt.transferWithCallback(address(market), price, abi.encode(buyData));

        vm.startPrank(alice);
        usdt.transfer(tom, price);
        vm.startPrank(tom);
        usdt.transferWithCallback(address(market), price, abi.encode(buyData));

        assertEq(nft.ownerOf(tokenId), tom, "Buy Success");
        assertEq(usdt.balanceOf(tom), 0, "Pay Money Success");
        assertEq(usdt.balanceOf(alice), 1e18, "Make Money Success");
        assertEq(
            market.ownerOf(address(nft), tokenId),
            address(0),
            "Market unlist success"
        );
    }

    function buyNFT(uint256 tokenId, uint256 price) private {
        vm.startPrank(alice);

        /**
         * 预期错误：没有授权ERC20
         *
         */
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientAllowance(address,uint256,uint256)",
                address(market),
                0,
                price
            )
        );
        market.buyNFT(address(nft), tokenId, address(usdt));

        usdt.approve(address(market), price);
        /**
         * 预期错误：buyer is not seller
         *
         */
        vm.expectRevert("buyer is not seller");
        market.buyNFT(address(nft), tokenId, address(usdt));

        /**
         * 预期错误：余额不足
         */
        vm.startPrank(tom);
        usdt.approve(address(market), price);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientBalance(address,uint256,uint256)",
                address(tom),
                0,
                price
            )
        );
        market.buyNFT(address(nft), tokenId, address(usdt));

        // 切换Alice转账 Tom
        vm.startPrank(alice);
        usdt.transfer(address(tom), price);
        vm.startPrank(tom);
        usdt.approve(address(market), price);
        market.buyNFT(address(nft), tokenId, address(usdt));
        assertEq(nft.ownerOf(tokenId), tom, "Buy Success");
        assertEq(usdt.balanceOf(tom), 0, "Pay Money Success");
        assertEq(usdt.balanceOf(alice), 1e18, "Make Money Success");
        assertEq(
            market.ownerOf(address(nft), tokenId),
            address(0),
            "Market unlist success"
        );

        /**
         * 预期错误：用户没有挂单
         *
         */
        vm.startPrank(alice);
        vm.expectRevert(
            abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0))
        );
        market.buyNFT(address(nft), tokenId, address(usdt));
    }
}
