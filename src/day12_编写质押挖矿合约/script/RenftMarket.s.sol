// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {RenftMarket} from "../src/RenftMarket.sol";
import {NFTFactory} from "../src/NFTFactory.sol";

contract RenftMarketScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(msg.sender);
        NFTFactory _NFTFactory = new NFTFactory();
        _NFTFactory.deployNFT(
            "Nothan",
            "N",
            "ipfs://Qmdqw4sXTEzwCKEKiRDJ7cuBr3uD9MTjdn92pU7PHbZjVG/",
            1000
        );
        new RenftMarket();
    }
}
