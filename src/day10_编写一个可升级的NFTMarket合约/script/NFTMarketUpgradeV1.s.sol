// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import {Script, console} from "forge-std/Script.sol";
import "forge-std/Script.sol";
// import "./BaseScript.s.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NFTMarketUpgradeV1Script is Script{
    function run() public {
        vm.startBroadcast(msg.sender);

        // vm.broadcast();
        Options memory opts;
        //   opts.unsafeSkipAllChecks = true;
        opts.unsafeSkipAllChecks = true;
        address proxy = Upgrades.deployTransparentProxy(
            "NFTMarketV1.sol:NFTMarketV1",
            msg.sender, // INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN,
            "", // abi.encodeCall(MyContract.initialize, ("arguments for the initialize function")
            opts
        );

        console.log("Counter deployed on %s", address(proxy));
    }
}
