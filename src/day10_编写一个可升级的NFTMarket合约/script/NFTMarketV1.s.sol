// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
contract NFTMarketV1Script is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        NFTMarketV1 nftMarketProxy = new NFTMarketV1();
        console.log(address(nftMarketProxy));
    }
}
