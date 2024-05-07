// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
contract NFTMarketV2Script is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        NFTMarketV2 nftMarketProxy = new NFTMarketV2(
            
        );
        console.log(address(nftMarketProxy));
    }
}
