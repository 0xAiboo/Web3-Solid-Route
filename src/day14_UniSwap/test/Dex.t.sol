// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {UniswapV2Factory} from "../contracts/v2-core/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../contracts/v2-core/UniswapV2Pair.sol";
import {UniswapV2Router02} from "../contracts/v2-periphery/UniswapV2Router02.sol";
import {RNT} from "../src/RNT.sol";
// import {WETH} from "../src/WETH.sol";
import {WETH9} from "../contracts/v2-periphery/test/WETH9.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Dex} from "../src/Dex.sol";
contract DexTest is Test {
    using Strings for uint256;
    SigUtils internal sigUtils;

    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address pair;
    UniswapV2Router02 uniswapV2Router02;
    UniswapV2Factory factory;
    Dex dex;
    RNT rnt;
    WETH9 weth;
    function setUp() public {
        vm.startPrank(alice);
        factory = new UniswapV2Factory(address(alice));
        rnt = new RNT();
        weth = new WETH9();
        pair = factory.createPair(address(weth), address(rnt));
        // uniswapV2Router02 = new UniswapV2Router02(
        //     address(factory),
        //     address(weth)
        // );
        dex = new Dex(address(factory), address(weth));
        // UniswapV2Pair ercPair = UniswapV2Pair(pair);
        weth.approve(address(dex), 99999999999999999999 * 1e18);
        rnt.approve(address(dex), 99999999999999999999 * 1e18);
        vm.stopPrank();
    }
    function test_mint() public {
        vm.startPrank(alice);
        vm.deal(alice, 10000 ether);
        rnt.transfer(address(tom), 1_000_000 * 1e18);
        dex.addLiquidityETH{value: 10000 ether}(
            address(rnt),
            1_000_000 * 1e18,
            1_000_000 * 1e18,
            100 * 1e18,
            address(alice),
            10 days
        );
        
        vm.stopPrank();
    }
    function test_swap() public {
        test_mint();
        vm.startPrank(tom);
        vm.deal(tom, 10000 ether);
        address[] memory addre = new address[](2);
        addre[0] = address(weth);
        addre[1] = address(rnt);
        console.log(rnt.balanceOf(address(tom)));
        dex.sellETH{value: 1000 ether}(address(rnt), 100 * 1e18);
        // uniswapV2Router02.swapExactETHForTokens{value: 10 ether}(
        //     100 * 1e18,
        //     addre,
        //     address(tom),
        //     10 days
        // );
        vm.stopPrank();
    }
    function test_buyETH() public {
        test_mint();
        vm.startPrank(tom);
        vm.deal(tom, 10000 ether);
        address[] memory addre = new address[](2);
        addre[1] = address(weth);

        addre[0] = address(rnt);
        rnt.approve(address(dex), 99999999999999999999 * 1e18);
        dex.buyETH(address(rnt), 10 * 1e18, 1);
        vm.stopPrank();

        vm.startPrank(tom);
    }
}
