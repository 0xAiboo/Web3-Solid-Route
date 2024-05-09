// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interface/IRenftMarket.sol";
import "./utils/Signature.sol";
/**
 * @title RenftMarket
 * @dev NFT租赁市场合约
 *   TODO:
 *      1. 退还NFT：租户在租赁期内，可以随时退还NFT，根据租赁时长计算租金，剩余租金将会退还给出租人
 *      2. 过期订单处理：
 *      3. 领取租金：出租人可以随时领取租金
 */
contract RenftMarket is IRenftMarket, EIP712 {
    IERC721 ierc721;
    mapping(bytes32 => BorrowOrder) public orders; // 已租赁订单
    mapping(bytes32 => bool) public canceledOrders; // 已取消的挂单
    string private constant marketName = "RenftMarket";
    string private constant version = "1";
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "RentoutOrder(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)"
        );
    constructor() EIP712(marketName, version) {}

    /**
     * @notice 租赁NFT
     * @dev 验证签名后，将NFT从出租人转移到租户，并存储订单信息
     */
    function borrow(
        RentoutOrder calldata order,
        bytes calldata makerSignature
    ) external payable {
        // revert("TODO");
        bytes32 borrowHash = this.orderHash(order);
        // 订单已取消
        if (canceledOrders[borrowHash]) revert ErrorOrderCancelled(order);
        if (orders[borrowHash].taker != address(0))
            revert ErrorOrderRented(order);
        if (order.list_endtime < block.timestamp)
            revert ErrorOrderExpired(order);
 
        if (msg.value < order.min_collateral)
            revert ErrorMoneyInsufficient(msg.value, order.min_collateral);
        // 验证挂单
        _verifyOrder(order, makerSignature);
        _GenerateOrder(order, borrowHash);
        emit BorrowNFT(msg.sender, order.maker, borrowHash, msg.value);
    }

    /**
     * 1. 取消时一定要将取消的信息在链上标记，防止订单被使用！
     * 2. 防DOS： 取消订单有成本，这样防止随意的挂单，
     */
    function cancelOrder(
        RentoutOrder calldata order,
        bytes calldata makerSignatre
    ) external {
        // revert("TODO");
        bytes32 borrowHash = this.orderHash(order);
        if (canceledOrders[borrowHash]) revert ErrorOrderCancelled(order);
        _verifyOrder(order, makerSignatre);
        canceledOrders[borrowHash] = true;
        emit OrderCanceled(order.maker, borrowHash);
    }

    // 计算订单哈希
    function orderHash(
        RentoutOrder calldata order
    ) external pure returns (bytes32) {
        // revert("TODO");
        return
            keccak256(
                abi.encode(
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

    function _GenerateOrder(
        RentoutOrder calldata order,
        bytes32 borrowHash
    ) internal {
        BorrowOrder memory _borrowOrder = BorrowOrder(
            msg.sender,
            msg.value,
            block.timestamp,
            order
        );
        IERC721(order.nft_ca).safeTransferFrom(
            order.maker,
            _borrowOrder.taker,
            order.token_id
        );
        orders[borrowHash] = _borrowOrder;
    }
    /**
     * 验证订单签名
     */
    function _verifyOrder(
        RentoutOrder calldata order,
        bytes calldata makerSignature
    ) internal view {
        bytes32 hashStruct = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                order.maker,
                order.nft_ca,
                order.token_id,
                order.daily_rent,
                order.max_rental_duration,
                order.min_collateral,
                order.list_endtime
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", _domainSeparatorV4(), hashStruct)
        );

        (uint8 v, bytes32 r, bytes32 s) = Signature.toVRS(makerSignature);
        address signer = ecrecover(hash, v, r, s);
        if (signer != order.maker || signer == address(0))
            revert ErrorWrongSigner(signer, order.maker);
    }
}
