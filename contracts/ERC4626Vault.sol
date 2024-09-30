// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ERC4626Vault is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public totalAssets0;
    uint256 public totalAssets1;

    constructor(address _token0, address _token1) ERC20("ERC4626 Vault Token", "VAULT4626") {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    /// @notice Deposit tokens into the vault and receive vault shares
    function deposit(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 shares) {
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");

        // Transfer the underlying tokens from user to vault
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        // Calculate how many shares to mint based on the deposit amounts
        if (totalSupply() == 0) {
            shares = sqrt(amount0 * amount1);
        } else {
            shares = min(
                (amount0 * totalSupply()) / totalAssets0,
                (amount1 * totalSupply()) / totalAssets1
            );
        }

        // Update vault asset balances
        totalAssets0 += amount0;
        totalAssets1 += amount1;

        // Mint vault shares to the depositor
        _mint(msg.sender, shares);

        emit Deposit(msg.sender, amount0, amount1, shares);
    }

    /// @notice Withdraw tokens by burning shares
    function withdraw(uint256 shares) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        require(shares > 0, "Invalid share amount");

        // Calculate the underlying amounts to withdraw based on the share amount
        uint256 supply = totalSupply();
        amount0 = (shares * totalAssets0) / supply;
        amount1 = (shares * totalAssets1) / supply;

        // Burn the user's shares
        _burn(msg.sender, shares);

        // Update vault asset balances
        totalAssets0 -= amount0;
        totalAssets1 -= amount1;

        // Transfer the underlying tokens back to the user
        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);

        emit Withdraw(msg.sender, shares, amount0, amount1);
    }

    /// @notice Calculate the total value of assets in the vault
    function totalAssets() public view returns (uint256 total0, uint256 total1) {
        total0 = totalAssets0;
        total1 = totalAssets1;
    }

    /// @notice Utility function to calculate the square root of a number
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

    /// @notice Utility function to calculate the minimum of two numbers
    function min(uint x, uint y) private pure returns (uint) {
        return x < y ? x : y;
    }

    event Deposit(address indexed user, uint256 amount0, uint256 amount1, uint256 shares);
    event Withdraw(address indexed user, uint256 shares, uint256 amount0, uint256 amount1);
}
