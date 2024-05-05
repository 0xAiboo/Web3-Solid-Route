// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {Base721Token} from "../src/Base721Token.sol";
import {Base20Token} from "../src/Base20Token.sol";
contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        address deployer = makeAddr(
            "0xf7F8d93ad9C069e665CC7dC9a33F506331CCD3Dc"
        );
        new NFTMarket();
        new Base20Token("USDA", "Ather", 1e18);
        Base721Token nft = new Base721Token(
            "Azuki",
            "A",
            "ipfs://QmSGnRw91H155QEWkat4peXM5uDe4J4gkNzxQomkZ1dida/"
        );
        nft.mint(deployer, 1);
        nft.mint(deployer, 2);

        // vm.stopBroadcast();
    }
}
