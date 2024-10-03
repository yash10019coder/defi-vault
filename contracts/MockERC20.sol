// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockERC20 is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply,
        address ownerAddress
    ) ERC20(name, symbol) Ownable(ownerAddress) {
        _mint(msg.sender, initialSupply * (10 ** decimals));
    }

// Mint new tokens (only owner can call this)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

// Burn tokens
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
