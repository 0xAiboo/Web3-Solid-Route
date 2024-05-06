// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {NFTMarketProxy} from "../src/NFTMarketProxy.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
import {Base20Token} from "../src/Base20Token.sol";
import {Base721Token} from "../src/Base721Token.sol";
contract NFTMarketProxyTest is Test {
    NFTMarketProxy proxy;
    NFTMarketV2 nft2;
    NFTMarketV1 nft1;
    Base721Token token721;
    Base20Token token20;
    // 721 Owner
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address owner = makeAddr("owner");
    address token;
    SigUtils internal sigUtils;

    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(owner);
        nft1 = new NFTMarketV1();
        nft2 = new NFTMarketV2();
        proxy = new NFTMarketProxy();

        vm.stopPrank();

        vm.startPrank(alice);
        token721 = new Base721Token("aa", "aa", "");
        token20 = new Base20Token("aa", "aa", 1e18);
        token721.mint(alice);
        vm.stopPrank();
    }
    function test_proxy() public {
        vm.startPrank(owner);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature(
                "_setImplementation(address)",
                address(nft1)
            )
        );
        vm.stopPrank();
        test_listNFT();
        test_upgrade();
        test_listPermit();
    }

    function test_listNFT() public {
        uint256 tokenId = 1;
        uint256 price = 1000;
        listNFT(tokenId, price);
    }
    function test_upgrade() public {
        uint256 tokenId = 1;
        uint256 price = 1000;
        vm.startPrank(owner);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature(
                "_setImplementation(address)",
                address(nft2)
            )
        );
        vm.stopPrank();
        vm.startPrank(alice);
        (, bytes memory _data) = address(proxy).call(
            abi.encodeWithSignature(
                "listPrice(address,uint256)",
                address(token721),
                tokenId
            )
        );
        uint256 _price = abi.decode(_data, (uint256));
        //查询挂单价格是否正确
        assertEq(_price, price, "expect listPrice error");
        (, bytes memory _dataUser) = address(proxy).call(
            abi.encodeWithSignature(
                "ownerOf(address,uint256)",
                address(token721),
                tokenId
            )
        );
        address _user = abi.decode(_dataUser, (address));
        // //查询挂单用户是否正确
        assertEq(_user, alice, "expect listPrice error");
    }
    function listNFT(uint256 tokenId, uint256 price) private {
        vm.startPrank(alice);
        token721.approve(address(proxy), tokenId);
        // nft1.list(address(token721), tokenId, price);
        (bool suc, ) = address(proxy).call(
            abi.encodeWithSignature(
                "list(address,uint256,uint256)",
                address(token721),
                tokenId,
                price
            )
        );
        (, bytes memory _data) = address(proxy).call(
            abi.encodeWithSignature(
                "queryPrice(address,uint256)",
                address(token721),
                tokenId
            )
        );
        uint256 _price = abi.decode(_data, (uint256));
        console.log(_price);
        //查询挂单价格是否正确
        assertEq(_price, price, "expect listPrice error");
        (, bytes memory _dataUser) = address(proxy).call(
            abi.encodeWithSignature(
                "queryOwner(address,uint256)",
                address(token721),
                tokenId
            )
        );
        address _user = abi.decode(_dataUser, (address));
        // //查询挂单用户是否正确
        assertEq(_user, alice, "expect listPrice error");
        vm.stopPrank();
    }

    function test_listPermit() public {
        address contractAddress = address(token721);
        uint256 tokenId = 3;
        uint256 price = 3000;
        listPermit(contractAddress, tokenId, price);
    }
    function listPermit(
        address contractAddress,
        uint256 tokenId,
        uint256 price
    ) public {
        sigUtils = new SigUtils(token721.DOMAIN_SEPARATOR());

        vm.startPrank(alice);

        token721.mint(alice);
        token721.mint(alice);
        token721.mint(alice);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(alice),
            spender: address(proxy),
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

        (bool ss, ) = address(proxy).call(
            abi.encodeWithSignature(
                "permitList(address,address,address,uint256,uint256,uint256,uint8,bytes32,bytes32)",
                address(alice),
                address(proxy),
                contractAddress,
                price,
                tokenId,
                1 days,
                v,
                r,
                s
            )
        );

        (, bytes memory _data) = address(proxy).call(
            abi.encodeWithSignature(
                "listPrice(address,uint256)",
                address(token721),
                tokenId
            )
        );
        uint256 _price = abi.decode(_data, (uint256));
        //查询挂单价格是否正确
        assertEq(_price, price, "expect listPrice error");
        (, bytes memory _dataUser) = address(proxy).call(
            abi.encodeWithSignature(
                "ownerOf(address,uint256)",
                address(token721),
                tokenId
            )
        );
        address _user = abi.decode(_dataUser, (address));
        // //查询挂单用户是否正确
        assertEq(_user, alice, "expect listPrice error");
        // market.permitList(contractAddress, price, tokenId, 1 days, v, r, s);
        // assertEq(
        //     market.listPrice(contractAddress, tokenId),
        //     price,
        //     "permit list failed"
        // );
        // assertEq(
        //     market.ownerOf(contractAddress, tokenId),
        //     address(alice),
        //     "permit list failed"
        // );
        // assertEq(nft.ownerOf(tokenId), address(market), "permit list failed");

        // market.listPrice(tokenId);
    }
}
