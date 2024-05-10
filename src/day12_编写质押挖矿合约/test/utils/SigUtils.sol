// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor() {
        // DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;

        DOMAIN_SEPARATOR = 0xd0a5dde28c34bdbdbd1e10e6fae895390e17e1ca1c99bdc9b827a415b0d5e13b;
    }

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "RentoutOrder(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)"
        );

    struct RentoutOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 daily_rent; // 每日租金
        uint256 max_rental_duration; // 最大租赁时长
        uint256 min_collateral; // 最小抵押
        uint256 list_endtime; // 挂单结束时间
    }
    // computes the hash of a permit
    function getStructHash(
        RentoutOrder memory order
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    order.maker,
                    order.nft_ca,
                    order.token_id,
                    order.daily_rent,
                    order.max_rental_duration,
                    order.min_collateral,
                    order.list_endtime
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(
        RentoutOrder memory _permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }
}
