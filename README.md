# ERC4626 Vaults with Incentive Segregation in Uniswap V2

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Setup and Deployment](#setup-and-deployment)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Deployment Steps](#deployment-steps)
- [Running Tests](#running-tests)
- [Detailed Explanation](#detailed-explanation)
    - [ERC4626 Vault Usage](#erc4626-vault-usage)
    - [User Contributions Tracking](#user-contributions-tracking)
    - [Reward Distribution](#reward-distribution)
- [Contracts Overview](#contracts-overview)
- [License](#license)

---

## Overview

This project involves creating an advanced ERC4626-compliant vault that integrates with Uniswap V2, implements a custom staking mechanism, and utilizes the ERC4626 standard for tracking user contributions and distributing rewards. The vault accepts two ERC20 tokens, provides liquidity to Uniswap V2 pools, stakes the resulting LP tokens, and distributes rewards proportionally based on user shares.

---

## Project Structure

```
├── contracts
│   ├── ERC4626Vault.sol       // ERC4626-compliant vault contract
│   ├── Strategy.sol           // Strategy contract managing vault, Uniswap V2, and staking
│   ├── CustomStaking.sol      // Custom staking contract for LP tokens
│   ├── UniswapV2Factory.sol   // Uniswap V2 Factory contract
│   ├── UniswapV2Pair.sol      // Uniswap V2 Pair (liquidity pool) contract
│   ├── UniswapV2Router.sol    // Uniswap V2 Router contract
│   ├── MockERC20.sol          // Mock ERC20 tokens for testing
│   └── RewardToken.sol        // Custom reward token contract
├── scripts
│   └── deploy.js              // Deployment script using ethers.js
├── test
│   └── test.js                // Test cases for contracts
├── .env                       // Environment variables
├── package.json               // NPM package configuration
├── hardhat.config.ts          // Hardhat configuration file
└── README.md                  // Project documentation
```

---

## Setup and Deployment

### Prerequisites

- **Node.js** and **npm** installed
- **Hardhat** installed globally or as a dev dependency
- **Git** installed
- An Ethereum wallet with testnet ETH (if deploying to a testnet)
- RPC URL and private key (for deployment)

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/erc4626-vault.git
   cd erc4626-vault
   ```

2. **Install Dependencies**

   ```bash
   npm install
   ```

3. **Set Up Environment Variables**

   Create a `.env` file in the project root and add:

   ```bash
   RPC_URL=<Your_RPC_URL>
   PRIVATE_KEY=<Your_Private_Key>
   ```

    - Replace `<Your_RPC_URL>` with your Ethereum node's RPC URL (e.g., Infura or Alchemy).
    - Replace `<Your_Private_Key>` with your wallet's private key (ensure this is secure and only used for testing).

### Deployment Steps

1. **Compile Contracts**

   ```bash
   npx hardhat compile
   ```

2. **Run Deployment Script**

   ```bash
   node scripts/deploy.js
   ```

   This script will:

    - Deploy mock ERC20 tokens (`TokenA`, `TokenB`, `RewardToken`).
    - Deploy the `CustomStaking` contract.
    - Deploy the `UniswapV2Factory`, `UniswapV2Router`, and `UniswapV2Pair` contracts.
    - Deploy the `ERC4626Vault` contract.
    - Deploy the `Strategy` contract.

3. **Deployment Output**

   The script will output the addresses of the deployed contracts. Make sure to save these for interacting with the contracts during testing.

---

## Running Tests

1. **Configure Test Network**

   Ensure your Hardhat network configuration in `hardhat.config.ts` is set up correctly for local or testnet testing.

2. **Write Test Cases**

   Tests are located in the `test` directory. The `test.js` file includes unit and integration tests covering:

    - Depositing into the vault.
    - Providing liquidity to Uniswap V2.
    - Staking LP tokens.
    - Reward distribution.
    - Withdrawing from the vault.

3. **Run Tests**

   ```bash
   npx hardhat test
   ```

   This command will execute all the test cases and output the results to the console.

---

## Detailed Explanation

### ERC4626 Vault Usage

The `ERC4626Vault` contract is central to the project's functionality. It complies with the ERC4626 standard, providing a standardized interface for tokenized vaults.

- **Accepts Deposits**: Users can deposit two ERC20 tokens (`TokenA` and `TokenB`) into the vault.
- **Mints Shares**: Upon deposit, the vault mints shares to users proportional to their contribution.
- **Tracks Total Assets**: Maintains records of the total assets (`totalAssets0` and `totalAssets1`) held in the vault.
- **Facilitates Withdrawals**: Users can burn their shares to withdraw their proportional share of the underlying assets.

### User Contributions Tracking

- **Share Accounting**: The vault's share system tracks each user's contribution to the total assets.
- **Proportional Ownership**: The number of shares a user holds represents their proportionate ownership in the vault.
- **Accurate Records**: The vault updates total assets and user balances on every deposit and withdrawal, ensuring accurate tracking.

### Reward Distribution

- **Staking LP Tokens**: The `Strategy` contract stakes LP tokens obtained from Uniswap V2 into the `CustomStaking` contract.
- **Reward Accrual**: The staking contract accumulates rewards over time based on staked amounts.
- **Calculating User Rewards**:
    - **Proportional to Shares**: Rewards are calculated based on the user's share of the total vault supply.
    - **Formula**: `userRewards = (userShares * totalRewards) / totalShares`.
- **Claiming Rewards**: Users can claim their rewards through the `claimRewards` function in the `Strategy` contract.
- **Reinvesting Rewards**: Rewards can be reinvested back into the vault, compounding the user's returns.

---

## Contracts Overview

### ERC4626Vault.sol

- **Purpose**: Manages user deposits, minting shares, and withdrawals.
- **Key Functions**:
    - `deposit(uint256 amount0, uint256 amount1)`: Users deposit tokens and receive shares.
    - `withdraw(uint256 shares)`: Users burn shares to withdraw underlying assets.
    - `totalAssets()`: Returns the total assets held by the vault.

### Strategy.sol

- **Purpose**: Orchestrates interactions between the vault, Uniswap V2, and staking contract.
- **Key Functions**:
    - `deposit(uint256 amountA, uint256 amountB)`: Handles deposits, liquidity provision, and staking.
    - `withdraw(uint256 shares)`: Handles unstaking, liquidity removal, and asset withdrawal.
    - `claimRewards()`: Allows users to claim their accrued rewards.
    - `reinvestRewards()`: Reinvests rewards into the vault.

### CustomStaking.sol

- **Purpose**: Manages staking of LP tokens and distributes rewards.
- **Key Functions**:
    - `stake(uint256 amount)`: Stakes LP tokens.
    - `unstake(uint256 amount)`: Unstakes LP tokens and transfers rewards.
    - `claimRewards()`: Users claim their staking rewards.
    - `calculateReward(address user)`: Calculates rewards for a user.

### UniswapV2 Contracts

- **Factory**: Deploys new liquidity pools (pairs).
- **Router**: Facilitates adding/removing liquidity and swapping tokens.
- **Pair**: Represents the liquidity pool for two tokens.

### MockERC20.sol

- **Purpose**: Provides mock ERC20 tokens (`TokenA`, `TokenB`, `RewardToken`) for testing.
- **Key Functions**:
    - Standard ERC20 functions (`transfer`, `approve`, `transferFrom`).

---

## License

This project is licensed under the MIT License.

---
