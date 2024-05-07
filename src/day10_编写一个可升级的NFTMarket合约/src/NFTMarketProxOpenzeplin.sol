// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import {console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract NFTMarketProxOpenzeplin is TransparentUpgradeableProxy {
    constructor(
        address logic,
        address admin,
        bytes memory a
    ) TransparentUpgradeableProxy(logic, admin, a) {}
    function getAddminAddress() external returns (address) {
        return _proxyAdmin();
        // super.getAdmin();
    }
    receive() external payable {
        // Triggered when Ether is sent to the contract with no calldata
        _fallback();
    }
}
