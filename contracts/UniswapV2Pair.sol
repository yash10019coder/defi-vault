// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract UniswapV2Pair is ERC20, ReentrancyGuard {
    address public token0;
    address public token1;
    uint112 private reserve0;
    uint112 private reserve1;

    constructor() ERC20("Uniswap V2 LP Token", "UNI-V2") {}

    function initialize(address _token0, address _token1) external {
        require(token0 == address(0) && token1 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    // Add liquidity to the pool
    function addLiquidity(uint amount0, uint amount1) external nonReentrant returns (uint liquidity) {
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        if (totalSupply() == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min((amount0 * totalSupply()) / reserve0, (amount1 * totalSupply()) / reserve1);
        }

        _mint(msg.sender, liquidity);

        _update(amount0, amount1);
    }

    // Remove liquidity from the pool
    function removeLiquidity(uint liquidity) external nonReentrant returns (uint amount0, uint amount1) {
        require(balanceOf(msg.sender) >= liquidity, "Not enough liquidity");

        uint _totalSupply = totalSupply();
        amount0 = (liquidity * reserve0) / _totalSupply;
        amount1 = (liquidity * reserve1) / _totalSupply;

        _burn(msg.sender, liquidity);
        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);

        _update(reserve0 - uint112(amount0), reserve1 - uint112(amount1));
    }

    // Swap tokens within the liquidity pool
    function swap(uint amount0Out, uint amount1Out, address to) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1) = getReserves();

        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        require(balance0 * balance1 >= uint(_reserve0) * uint(_reserve1), "UniswapV2: K");

        _update(balance0, balance1);
    }

    function _update(uint balance0, uint balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        return z;
    }

    function min(uint x, uint y) private pure returns (uint) {
        return x < y ? x : y;
    }
}
