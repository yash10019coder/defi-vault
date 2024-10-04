// Script to deploy Strategy and CustomStaking contracts using ethers.js
// Make sure to have ethers.js installed and configured
// And the contract JSON ABI & Bytecode must be available after compiling them

import { ethers } from "hardhat";

import { config } from "dotenv";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import * as fs from "node:fs";

config();

// Load compiled contract artifacts (ABI and Bytecode)
function loadContract(contractName: string) {
  const filePath = `./artifacts/contracts/${contractName}.sol/${contractName}.json`;
  const contract = JSON.parse(fs.readFileSync(filePath, "utf8"));
  return contract;
}

// Function to deploy a contract
async function deployContract(contractName: string, args: Array<any>, signer: any) {
  const contract = loadContract(contractName);
  const factory = new ethers.ContractFactory(contract.abi, contract.bytecode, signer);
  // console.log(`${contractName} deployed at: ${deployedContract.}`);
  return await factory.deploy(...args);
}

(async () => {
  try {
    let accounts: SignerWithAddress[] = await ethers.getSigners();
    console.log(`Accounts: ${accounts.map(account => account.address)}`);
    let ownerAddress: string = accounts[0].address;
    let signer = accounts[0];
    let feeToSetter: string = accounts[1].address;


    // Deploy ERC20 Mock Tokens (if needed)
    const mockToken1 = await deployContract("MockERC20", ["TokenA", "TKA", 18, "1000000000000000000000", ownerAddress], signer); // Initial supply for TokenA
    console.log(`TokenA deployed at: ${mockToken1.runner.address}`);

    const mockToken2 = await deployContract("MockERC20", ["TokenB", "TKB", 18, "1000000000000000000000", ownerAddress], signer); // Initial supply for TokenB
    console.log(`TokenB deployed at: ${mockToken2.runner.address}`);

    // Deploy reward token
    const rewardToken = await deployContract("MockERC20", ["RewardToken", "RWD", 18, "1000000000000000000000", ownerAddress], signer); // Initial supply for RewardToken
    console.log(`RewardToken deployed at: ${rewardToken.runner.address}`);

    // Deploy liquidity pool token
    const lpToken = await deployContract("MockERC20", ["LP Token", "LPT", 18, "1000000000000000000000", ownerAddress], signer); // Initial supply for LP Token
    console.log(`LP Token deployed at: ${lpToken.runner.address}`);

    // Deploy CustomStaking contract
    const customStaking = await deployContract("CustomStaking", [lpToken.runner.address, rewardToken.runner.address], signer);
    console.log(`CustomStaking deployed at: ${customStaking.runner.address}`);

    // Deploy ERC4626Vault contract (if you have it)
    const erc4626Vault = await deployContract("ERC4626Vault", [mockToken1.runner.address, mockToken2.runner.address], signer); // Adjust args as necessary
    console.log(`ERC4626Vault deployed at: ${erc4626Vault.runner.address}`);

    // Deploy UniswapV2Factory contract (if you have it)
    const uniswapFactory = await deployContract("UniswapV2Factory", [feeToSetter, ownerAddress], signer);


    // Deploy UniswapV2Router contract (if you have it)
    const uniswapRouter = await deployContract("UniswapV2Router", [uniswapFactory.runner.address], signer); // Adjust args as necessary
    console.log(`UniswapV2Router deployed at: ${uniswapRouter.runner.address}`);

    // Deploy Strategy contract
    const strategy = await deployContract("Strategy", [
      erc4626Vault.runner.address,
      uniswapRouter.runner.address,
      customStaking.runner.address,
      rewardToken.runner.address,
      mockToken1.runner.address,
      mockToken2.runner.address
    ], signer);
    console.log(`Strategy deployed at: ${strategy.runner.address}`);
  } catch (e) {
    console.log(`Error in deployment: ${e.message}`);
  }
})();
