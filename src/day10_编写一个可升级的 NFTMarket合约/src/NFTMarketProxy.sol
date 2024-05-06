// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import {console} from "forge-std/Test.sol";

contract NFTMarketProxy {
    address private implementation;
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 internal constant ADMIN_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);
    error adminAddressError(address implementationAddress);
    error implementationAddressError(address implementationAddress);

    constructor() {
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = msg.sender;
    }
    function _delegate(address _implementationAddress) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                _implementationAddress,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }
    function _setAdmin(address _adminAddress) external {
        if (_adminAddress.code.length <= 0 || msg.sender != _getAdmin())
            revert adminAddressError(_adminAddress);
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _adminAddress;
    }
    function upgradeTo(address _implementationAddress) external {
        _setImplementation(_implementationAddress);
    }
    function _implementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }
    function _setImplementation(address _implementationAddress) internal {
        if (_implementationAddress.code.length <= 0)
            revert implementationAddressError(_implementationAddress);
        StorageSlot
            .getAddressSlot(IMPLEMENTATION_SLOT)
            .value = _implementationAddress;
    }
    function _fallback() internal {
        if (msg.sender != _getAdmin()) {
            _delegate(_implementation());
        } else {
            (address _implementationAddress) = abi.decode(
                msg.data[4:],
                (address)
            );
            _setImplementation(_implementationAddress);
        }
    }
    fallback() external payable {
        _fallback();
    }
    receive() external payable {
        _fallback();
    }
}
