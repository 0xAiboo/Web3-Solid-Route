// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";
contract MyTokenScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new MyToken("Tether","USDT");
    }
}
