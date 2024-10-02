// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./UniswapV2Factory.sol";
import "./UniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniswapV2Router {
    using SafeERC20 for IERC20;

    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    /// @notice Adds liquidity to a pair, receiving LP tokens in return
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        address pair = UniswapV2Factory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = UniswapV2Factory(factory).createPair(tokenA, tokenB);
        }

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired);

        // Transfer tokens from user to the pair contract
        IERC20(tokenA).safeTransferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, pair, amountB);

        // Call mint inside the pair to issue LP tokens
        liquidity = UniswapV2Pair(pair).addLiquidity(amountA, amountB, msg.sender);
    }

    /// @notice Removes liquidity from a pair, returning tokens to the user
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity
    ) external returns (uint256 amountA, uint256 amountB) {
        address pair = UniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pair != address(0), "UniswapV2Router: PAIR_NOT_EXISTS");

        // Transfer the LP tokens from the user to the pair contract
        IERC20(pair).safeTransferFrom(msg.sender, pair, liquidity);

        // Call burn inside the pair to remove liquidity
        (amountA, amountB) = UniswapV2Pair(pair).removeLiquidity(msg.sender);
    }

    /// @notice Swap an exact amount of input tokens for output tokens
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Router: INVALID_PATH");

        amounts = _getAmountsOut(amountIn, path);

        require(amounts[amounts.length - 1] >= amountOutMin, "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");

        // Transfer input token to the first pair
        IERC20(path[0]).safeTransferFrom(msg.sender, UniswapV2Factory(factory).getPair(path[0], path[1]), amounts[0]);

        // Perform the swap along the path
        _swap(amounts, path, msg.sender);
    }

    /// @notice Internal function for adding liquidity to a pair
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    ) internal view returns (uint256 amountA, uint256 amountB) {
        (uint256 reserveA, uint256 reserveB) = _getReserves(tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = (amountBDesired * reserveA) / reserveB;
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    /// @dev Internal function for swapping tokens along a path
    function _swap(uint256[] memory amounts, address[] memory path, address _to) internal {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            address pair = UniswapV2Factory(factory).getPair(input, output);
            (address token0, ) = input < output ? (input, output) : (output, input);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            UniswapV2Pair(pair).swap(amount0Out, amount1Out, _to);
        }
    }

    /// @dev Internal function to get reserves for a token pair
    function _getReserves(address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        address pair = UniswapV2Factory(factory).getPair(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA < tokenB ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    /// @dev Calculates the output amounts for a swap
    function _getAmountsOut(uint256 amountIn, address[] memory path) internal view returns (uint256[] memory amounts) {
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            address pair = UniswapV2Factory(factory).getPair(path[i], path[i + 1]);
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(path[i], path[i + 1]);
            amounts[i + 1] = _getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    /// @dev Calculates the input amounts required for a swap
    function _getAmountsIn(uint256 amountOut, address[] memory path) internal view returns (uint256[] memory amounts) {
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            address pair = UniswapV2Factory(factory).getPair(path[i - 1], path[i]);
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(path[i - 1], path[i]);
            amounts[i - 1] = _getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    /// @dev Calculates how much output tokens will be received for a given input
    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        uint256 amountInWithFee = amountIn * 997;
        return (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }

    /// @dev Calculates how much input tokens are needed for a desired output
    function _getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        return (reserveIn * amountOut * 1000) / ((reserveOut - amountOut) * 997) + 1;
    }
}
