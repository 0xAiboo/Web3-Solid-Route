// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketProxy} from "../src/NFTMarketProxy.sol";
contract NFTMarketProxyScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        NFTMarketProxy nftMarketProxy = new NFTMarketProxy();
        console.log(address(nftMarketProxy));
    }
}
