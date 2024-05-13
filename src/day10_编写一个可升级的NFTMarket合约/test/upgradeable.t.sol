// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {NFTMarketProxy} from "../src/NFTMarketProxy.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
import {NFTMarketProxOpenzeplin} from "../src/NFTMarketProxOpenzeplin.sol";
import {Base20Token} from "../src/Base20Token.sol";
import {Base721Token} from "../src/Base721Token.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
contract NFTMarketProxyTest is Test {
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
    address proxy;
    SigUtils internal sigUtils;
    // using ERC1967Utils;

    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(owner);

        vm.stopPrank();
        vm.startPrank(alice);
        token721 = new Base721Token("aa", "aa", "");
        token20 = new Base20Token("aa", "aa", 1e18);
        token20.transfer(tom, 1e18);
        token721.mint(alice);

        vm.stopPrank();
    }
    function test_proxy1() public {
        uint256 tokenId = 1;
        uint256 price = 1000;
        deployV1();
        List(tokenId, price);
        eqPriceOwner(tokenId, price);
        upgradeableV2();
        //先验证v1中的挂单状态
        eqPriceOwnerV2(tokenId, price);
        tokenId = 2;
        price = 2000;
        list_permit(tokenId, price);
        eqPriceOwnerV2(tokenId, price);
    }

    function deployV1() internal {
        vm.startPrank(owner);
        Options memory opts;
        //   opts.unsafeSkipAllChecks = true;
        opts.unsafeSkipAllChecks = true;
        proxy = Upgrades.deployTransparentProxy(
            "NFTMarketV1.sol:NFTMarketV1",
            owner, // INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN,
            "", // abi.encodeCall(MyContract.initialize, ("arguments for the initialize function")
            opts
        );
        vm.stopPrank();
    }
    function upgradeableV2() internal {
        vm.startPrank(owner);
        Options memory opts;
        opts.unsafeSkipAllChecks = true;
        opts.referenceContract = "NFTMarketV1.sol:NFTMarketV1";
        // proxy: 0xE51D179eD956500AC8E0dd535DDaf48775aD7832
       Upgrades.upgradeProxy(
            proxy,
            "NFTMarketV2.sol:NFTMarketV2",
            // "NFTMarketV2.initializers",
            abi.encodeWithSignature("initializers()"),
            // "NFTMarketV2.initializers",
            // abi.encodeCall(NFTMarketV2.initializers),
            opts
        );
        vm.stopPrank();
    }
    function List(uint256 tokenId, uint256 price) internal {
        vm.startPrank(alice);
        token721.approve(address(proxy), tokenId);
        (bool suc, ) = proxy.call(
            abi.encodeWithSignature(
                "list(address,uint256,uint256)",
                address(token721),
                tokenId,
                price
            )
        );

        vm.stopPrank();
    }
    function eqPriceOwner(uint256 tokenId, uint256 price) internal {
        (, bytes memory _data) = address(proxy).call(
            abi.encodeWithSignature(
                "queryPrice(address,uint256)",
                address(token721),
                tokenId
            )
        );
        uint256 _price = abi.decode(_data, (uint256));
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
    }
    function eqPriceOwnerV2(uint256 tokenId, uint256 price) internal {
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
    function list_permit(uint256 tokenId, uint256 price) internal {
        (, bytes memory _domain) = address(proxy).call(
            abi.encodeWithSignature("_DOMAIN_SEPARATOR()")
        );
        bytes32 _domain32 = abi.decode(_domain, (bytes32));
        sigUtils = new SigUtils(_domain32);
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

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        console.log("=====================================================");
        token721.setApprovalForAll(address(proxy), true);
        (bool ss, ) = address(proxy).call(
            abi.encodeWithSignature(
                "permitList(address,address,address,uint256,uint256,uint256,uint8,bytes32,bytes32)",
                address(alice),
                address(proxy),
                address(token721),
                price,
                tokenId,
                1 days,
                v,
                r,
                s
            )
        );
    }
}
