// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DualTokenVault is ERC4626 {
    ERC20 public token0;
    ERC20 public token1;

    constructor(
        ERC20 _token0,
        ERC20 _token1
    ) ERC4626(_token0) ERC20("LP Vault Shares", "LPVS") {
        token0 = _token0;
        token1 = _token1;
    }

    // Deposit both tokens and mint shares
    function deposit(uint256 amount0, uint256 amount1, address receiver) external returns (uint256 shares) {
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);

        // Logic to mint shares proportionate to value of deposited tokens
        shares = previewDeposit(amount0 + amount1);
        _mint(receiver, shares);
        return shares;
    }

    // Withdraw both tokens and burn shares
    function withdraw(uint256 shares, address receiver) external returns (uint256 amount0, uint256 amount1) {
        _burn(msg.sender, shares);

        uint256 totalAssets = totalAssets();
        amount0 = (token0.balanceOf(address(this)) * shares) / totalAssets;
        amount1 = (token1.balanceOf(address(this)) * shares) / totalAssets;

        token0.transfer(receiver, amount0);
        token1.transfer(receiver, amount1);
        return (amount0, amount1);
    }

    function totalAssets() public view override returns (uint256) {
        // Combine token0 and token1 in the vault as the total assets
        return token0.balanceOf(address(this)) + token1.balanceOf(address(this));
    }
}
