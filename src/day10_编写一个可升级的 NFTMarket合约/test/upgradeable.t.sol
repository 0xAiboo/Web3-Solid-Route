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

import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
contract NFTMarketProxyTest is Test {
    NFTMarketProxy proxy;
    NFTMarketV2 nft2;
    NFTMarketV1 nft1;
    Base721Token token721;
    Base20Token token20;
    TransparentUpgradeableProxy tup;
    ITransparentUpgradeableProxy itup;
    NFTMarketProxOpenzeplin no;
    // 721 Owner
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address owner = makeAddr("owner");
    address token;
    SigUtils internal sigUtils;
    // using ERC1967Utils;

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
        no = new NFTMarketProxOpenzeplin(address(nft1), owner, "");
        vm.stopPrank();
    }
    function test_proxy1() public {
        vm.startPrank(owner);
        // tup = new TransparentUpgradeableProxy(address(nft1), owner, "");
        (, bytes memory _dd) = address(no).call(
            abi.encodeWithSignature("getAddminAddress()")
        );
        address dd = abi.decode(_dd, (address));
        // console.log(ERC1967Utils.getAdmin());
        // (bool success, ) = address(tup).call(
        //     abi.encodeWithSignature(
        //         "upgradeToAndCall(address,bytes)",
        //         address(nft2),
        //         ""
        //     )
        // );
        ITransparentUpgradeableProxy itupp = ITransparentUpgradeableProxy(
            address(no)
        );
        // console.logBytes(
        //     abi.encodeWithSignature(
        //         "upgradeAndCall(address,address,bytes)"
        //     )
        // );
        (bool success, ) = address(no.getAddminAddress()).call(
            abi.encodeWithSignature(
                "upgradeAndCall(address,address,bytes)",
                address(no),
                address(nft2),
                ""
            )
        );
        // address(dd).upgradeAndCall(itupp, address(nft2), "");
    }
    //  function test_proxy2() public {
    //     vm.startPrank(owner);
    //     // tup = new TransparentUpgradeableProxy(address(nft1), owner, "");
    //     // (, bytes memory _dd) = address(tup).call(
    //     //     abi.encodeWithSignature("_proxyAdmin()")
    //     // );
    //     // address dd = abi.decode(_dd, (address));

    //     console.log(ERC1967Utils.getAdmin());
    //     // (bool success, ) = address(tup).call(
    //     //     abi.encodeWithSignature(
    //     //         "upgradeToAndCall(address,bytes)",
    //     //         address(nft2),
    //     //         ""
    //     //     )
    //     // );
    //     // itup = ITransparentUpgradeableProxy(dd);
    //     // (bool success, ) = address(dd).call(
    //     //     abi.encodeWithSignature(
    //     //         "upgradeAndCall(ITransparentUpgradeableProxy,address,bytes)",
    //     //         itup,
    //     //         address(nft2),
    //     //         ""
    //     //     )
    //     // );
    // }
}
