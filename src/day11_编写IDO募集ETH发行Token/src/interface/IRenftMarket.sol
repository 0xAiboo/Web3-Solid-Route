// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IRenftMarket {
    // 出租订单事件
    event BorrowNFT(
        address indexed taker,
        address indexed maker,
        bytes32 orderHash,
        uint256 collateral
    );
    // 取消订单事件
    event OrderCanceled(address indexed maker, bytes32 orderHash);

    //订单已取消
    error ErrorOrderCancelled(RentoutOrder order);
    //签名错误
    error ErrorWrongSigner(address signer, address marker);
    //订单已出租
    error ErrorOrderRented(RentoutOrder order);
    //订单已失效
    error ErrorOrderExpired(RentoutOrder order);
    error ErrorMoneyInsufficient(uint256 collateral, uint256 daily_rent);

    struct RentoutOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 daily_rent; // 每日租金
        uint256 max_rental_duration; // 最大租赁时长
        uint256 min_collateral; // 最小抵押
        uint256 list_endtime; // 挂单结束时间
    }

    // 租赁信息
    struct BorrowOrder {
        address taker; // 租方人地址
        uint256 collateral; // 抵押
        uint256 start_time; // 租赁开始时间，方便计算利息
        RentoutOrder rentinfo; // 租赁订单
    }
    function cancelOrder(
        RentoutOrder calldata order,
        bytes calldata makerSignatre
    ) external;
    function orderHash(RentoutOrder calldata) external view returns (bytes32);
}
