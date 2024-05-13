// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {UniswapV2Factory} from "../core/UniswapV2Factory.sol";
import {RNT} from "../src/RNT.sol";
import {WETH} from "../src/WETH.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract DexTest is Test {
    using Strings for uint256;
    SigUtils internal sigUtils;

    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    UniswapV2Factory factory = new UniswapV2Factory();
    RNT rnt;
    WETH weth;
    function setUp() public {
        vm.startPrank(alice);
        factory = new UniswapV2Factory();
        rnt = new RNT();
        weth = new WETH();
        factory.createPair(weth, rnt);
        vm.stopPrank();
    }
    function test_buy() public {}
}
