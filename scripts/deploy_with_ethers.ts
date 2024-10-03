// Script to deploy Strategy and CustomStaking contracts using ethers.js
// Make sure to have ethers.js installed and configured
// And the contract JSON ABI & Bytecode must be available after compiling them

import { ethers } from "ethers";

import fs from "fs";

import { config } from "dotenv";

config();

// Load compiled contract artifacts (ABI and Bytecode)
function loadContract(contractName) {
  const filePath = `./artifacts/contracts/${contractName}.sol/${contractName}.json`;
  const contract = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  return contract;
}

// Function to deploy a contract
async function deployContract(contractName, args, signer) {
  const contract = loadContract(contractName);
  const factory = new ethers.ContractFactory(contract.abi, contract.bytecode, signer);
  const deployedContract = await factory.deploy(...args);
  await deployedContract.deployed();
  console.log(`${contractName} deployed at: ${deployedContract.address}`);
  return deployedContract;
}

(async () => {
  try {
    // Connect to a provider (e.g., a local node or testnet)
    const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    // 1. Deploy ERC20 Mock Tokens for tokenA, tokenB, and rewardToken
    console.log("Deploying ERC20 Mock Tokens...");
    const tokenA = await deployContract('MockERC20', ['TokenA', 'TKA'], signer);
    const tokenB = await deployContract('MockERC20', ['TokenB', 'TKB'], signer);
    const rewardToken = await deployContract('MockERC20', ['RewardToken', 'RWD'], signer);

    // 2. Deploy CustomStaking Contract
    console.log("Deploying CustomStaking Contract...");
    const stakingContract = await deployContract('CustomStaking', [tokenA.address, rewardToken.address], signer);

    // 3. Deploy UniswapV2Router (Mock or Real, based on your setup)
    console.log("Deploying UniswapV2Router Mock...");
    const uniswapRouter = await deployContract('UniswapV2Router', [], signer);

    // 4. Deploy ERC4626Vault (Mock or real based on your setup)
    console.log("Deploying ERC4626Vault Mock...");
    const vault = await deployContract('ERC4626Vault', [tokenA.address, tokenB.address], signer);

    // 5. Deploy Strategy Contract
    console.log("Deploying Strategy Contract...");
    const strategy = await deployContract('Strategy', [
      vault.address,
      uniswapRouter.address,
      stakingContract.address,
      rewardToken.address,
      tokenA.address,
      tokenB.address
    ], signer);

    console.log("All contracts deployed successfully!");

  } catch (e) {
    console.log(`Error in deployment: ${e.message}`);
  }
})();
