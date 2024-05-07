// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import {Script, console} from "forge-std/Script.sol";
import "forge-std/Script.sol";
// import "./BaseScript.s.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NFTMarketUpgradeV2Script is Script {
    function run() public {
        vm.startBroadcast(msg.sender);

        // vm.broadcast();
        Options memory opts;
        opts.unsafeSkipAllChecks = true;
        opts.referenceContract = "NFTMarketV1.sol:NFTMarketV1";

        // proxy: 0xE51D179eD956500AC8E0dd535DDaf48775aD7832
        Upgrades.upgradeProxy(
            0xE51D179eD956500AC8E0dd535DDaf48775aD7832,
            "NFTMarketV2.sol:NFTMarketV2",
            "",
            opts
        );
    }
}
