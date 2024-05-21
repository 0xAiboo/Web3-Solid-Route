// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "./interface/IDex.sol";
import "./library/DexLibrary.sol";
import "../contracts/v2-periphery/interfaces/IWETH.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {console} from "forge-std/Test.sol";

contract Dex is IDex {
    address public immutable factory;
    address public immutable WETH;
    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }
    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        virtual
        returns (uint amountToken, uint amountETH, uint liquidity)
    {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = DexLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IUniswapV2Pair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH)
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = DexLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );

        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = DexLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = DexLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function sellETH(
        address buyToken,
        uint256 minBuyAmount
    ) external payable override {
        // TODO: Implement sellETH
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = buyToken;
        if (buyToken == WETH) revert ERROR_DEX_SELL_ETH_FOR_ETH();
        uint[] memory amounts = DexLibrary.getAmountsOut(
            factory,
            msg.value,
            path
        );
        if (amounts[amounts.length - 1] < minBuyAmount)
            revert ERROR_DEX_INSUFFICIENT_OUTPUT_AMOUNT(
                amounts[amounts.length - 1],
                minBuyAmount
            );

        /**
         * 1.ETH不是标准的ERC-20所以先把ETH存入WETH合约中，交换等量的WETH(ERC-20)
         */
        IWETH(WETH).deposit{value: amounts[0]}();

        /**assert函数用作调试工具来检查代码中的不变量。它是一种检测应始终为真的条件的方法，
         * 如果失败，通常表明合同中存在缺陷或错误assert。
         * 与不同require，它用于输入验证和操作条件，assert用于确保代码逻辑本身没有错误。
         * 如果一条assert语句失败，则意味着合约代码中存在需要修复的错误。
         * */
        assert(
            IWETH(WETH).transfer(
                DexLibrary.pairFor(factory, WETH, buyToken),
                amounts[0]
            )
        );

        _swap(amounts, path, msg.sender);
    }
    function _swap(
        uint[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = DexLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0
                ? (uint(0), amountOut)
                : (amountOut, uint(0));
            address to = i < path.length - 2
                ? DexLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IUniswapV2Pair(DexLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }
    function buyETH(
        address sellToken,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external override {
        // TODO: Implement buyETH
        address[] memory path = new address[](2);
        path[1] = WETH;
        path[0] = sellToken;
        uint[] memory amounts = DexLibrary.getAmountsOut(
            factory,
            sellAmount,
            path
        );
        if (amounts[amounts.length - 1] < minBuyAmount)
            revert ERROR_DEX_INSUFFICIENT_OUTPUT_AMOUNT(
                amounts[amounts.length - 1],
                minBuyAmount
            );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            DexLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(msg.sender, amounts[amounts.length - 1]);
    }
}
