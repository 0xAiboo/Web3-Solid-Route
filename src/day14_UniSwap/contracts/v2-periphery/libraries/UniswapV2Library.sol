pragma solidity >=0.8.25;
import {console} from "forge-std/Test.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        // pair = 0x3c23AaAc3d156BDCe3e41aDa8Cfdc0771431D016;
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"deaef6a6cb14832e21740000c71978820ca378c2195799b03fdba7f51cdbb2a4" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint reserveA, uint reserveB) {
        console.log(pairFor(factory, tokenA, tokenB));
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();

        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) internal view returns (uint amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public view returns (uint amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        console.log("==============getAmountOut====================");
        // 兑换十个ETH

        //  uint amountInWithFee = amountIn.mul(997);
        // 10 * 997 = 9970

        //  uint numerator = amountInWithFee.mul(reserveOut);
        // 9970 * 1_000_000 = 9970_000_000

        //  uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        // 100*1000+9970 = 199700

        // amountOut = numerator / denominator;
        // 9970_000_000/199700 = 499249874686716792

        // 499249.874686716792 * 1e18 = 499249874686716792

        //                              90661089388014913158134
        //          我要兑换的 10ETH        池子所有的100ETH   池子所有的RNT：1_000_000
        // tokenAPond * tokenBPond =  (TokenAPond + amountIn) * (TokenBPond - amountOut)
        //             K           =            X             *         Y
        //  10 * 100 = (100+10) * (1_000_000 - amountOut)
        //  1000    = 110 * (1_000_000 - amountOut)
        // 1000/110 = 1_000_000 - amountOut
        // amountOut  = 999990.9090909091

        //  110 = (100 + 10*0.097) * (1_000_000 - amountOut)
        //  110 = (100 + 0.97) * (1_000_000 - amountOut)
        //  110 = 100.97 * (1_000_000 - amountOut)
        //  110/100.97 = 1_000_000 - amountOut
        //  1_000_000 - 110/100.97 = amountOut
        //  1_000_000 - 1.087 = amountOut
        //  999_999.912 = amountOut
        uint amountInWithFee = amountIn.mul(997); // 9970
        uint numerator = amountInWithFee.mul(reserveOut); // 9970* 1_000_000 = 9970_000_000
        uint denominator = reserveIn.mul(1000).add(amountInWithFee); // 100*1000+9970 = 109970

        amountOut = numerator / denominator;

        //  (10*997 * 1000000)/(100*1000+10*997)

        // uint amountInWithFee = amountIn.mul(997);
        // uint numerator = amountInWithFee.mul(reserveOut);
        // uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        // amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );

        uint numerator = reserveIn.mul(amountOut).mul(1000);
        //千分之三的手续费
        uint denominator = reserveOut.sub(amountOut).mul(997);
        // 为了防止0向上取整
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint amountIn,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint amountOut,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
