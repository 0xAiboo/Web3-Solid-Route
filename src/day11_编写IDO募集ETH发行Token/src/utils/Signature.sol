// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
library Signature {
    error InvalidSignature();
    function toVRS(
        bytes memory signature
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else {
            revert InvalidSignature();
        }
    }

    function fromVRS(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(r,s,v);
    }
}
