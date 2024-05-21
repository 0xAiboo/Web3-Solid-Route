// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
interface IDex {
    error ERROR_DEX_INSUFFICIENT_OUTPUT_AMOUNT(
        uint256 amount,
        uint256 minBuyAmount
    );
    error ERROR_DEX_SELL_ETH_FOR_ETH();
    /**
     * @dev 卖出ETH，兑换成 buyToken
     *      msg.value 为出售的ETH数量
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的 buyToken 数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable;

    /**
     * @dev 买入ETH，用 sellToken 兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(
        address sellToken,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external;
}
