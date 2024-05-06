// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarketProxy} from "../src/NFTMarketProxy.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
contract NFTMarketProxyTest is Test {
    NFTMarketProxy proxy;
    NFTMarketV2 ntt2;
    // 721 Owner
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address token;
    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(alice);
        ntt2 = new NFTMarketV2();
        proxy = new NFTMarketProxy();
    }
    function test_proxy() public {
        (bool success,) = address(proxy).call(
            abi.encodeWithSignature("_setImplementation(address)", address(ntt2))
        );
    }
}
