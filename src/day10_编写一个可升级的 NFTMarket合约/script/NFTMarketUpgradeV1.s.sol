// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NFTMarketUpgradeV1 is BaseScript {
    function run() public broadcaster {
        Options memory opts;
        //   opts.unsafeSkipAllChecks = true;

        address proxy = Upgrades.deployTransparentProxy(
            "NFTMarketV1.sol",
            deployer, // INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN,
            "", // abi.encodeCall(MyContract.initialize, ("arguments for the initialize function")
            opts
        );

        console.log("Counter deployed on %s", address(proxy));
    }
}
