import Web3, { ContractOptions } from "web3";
import { config } from "dotenv";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

// import { ContractSendMethod, Options } from "web3-eth-contract";

const web3Provider = "http://localhost:8545"; // Replace with your provider if necessary

config();

/**
 * Deploy the given contract
 * @param {string} contractName - Name of the contract to deploy
 * @param {Array<any>} args - List of constructor parameters
 * @param {string} from - Account used to send the transaction
 * @param {number} gas - Gas limit
 * @return {ContractOptions} - Deployed contract options
 */
const deploy = async (contractName: string, args: Array<any>, from?: string, gas?: number): Promise<ContractOptions> => {
  try {
    const web3 = new Web3(web3Provider);
    const accounts = await web3.eth.getAccounts();
    const contract = new web3.eth.Contract(require(`../artifacts/contracts/${contractName}.sol/${contractName}.json`).abi);
    const deployedContract = await contract.deploy({
      data: require(`../artifacts/contracts/${contractName}.sol/${contractName}.json`).bytecode,
      arguments: args
    }).send({ from: from || accounts[0], gas: String(gas) || "" + 6721975 });
    console.log(`${contractName} deployed at: ${deployedContract.options.address}`);
    return deployedContract.options;
  } catch (e) {
    console.error(`Error during deployment: ${e.message}`);
  }
};

(async () => {
  try {
    let accounts: SignerWithAddress[] = await ethers.getSigners();
    console.log(`Accounts: ${accounts.map(account => account.address)}`);
    let ownerAddress: string = accounts[0].address;


    // Deploy ERC20 Mock Tokens (if needed)
    const mockToken1 = await deploy("MockERC20", ["TokenA", "TKA", 18, "1000000000000000000000", ownerAddress]); // Initial supply for TokenA
    console.log(`TokenA deployed at: ${mockToken1.address}`);

    const mockToken2 = await deploy("MockERC20", ["TokenB", "TKB", 18, "1000000000000000000000", ownerAddress]); // Initial supply for TokenB
    console.log(`TokenB deployed at: ${mockToken2.address}`);

    // Deploy reward token
    const rewardToken = await deploy("MockERC20", ["RewardToken", "RWD", 18, "1000000000000000000000", ownerAddress]); // Initial supply for RewardToken
    console.log(`RewardToken deployed at: ${rewardToken.address}`);

    // Deploy liquidity pool token
    const lpToken = await deploy("MockERC20", ["LP Token", "LPT", 18, "1000000000000000000000", ownerAddress]); // Initial supply for LP Token
    console.log(`LP Token deployed at: ${lpToken.address}`);

    // Deploy CustomStaking contract
    const customStaking = await deploy("CustomStaking", [lpToken.address, rewardToken.address]);
    console.log(`CustomStaking deployed at: ${customStaking.address}`);

    // Deploy ERC4626Vault contract (if you have it)
    const erc4626Vault = await deploy("ERC4626Vault", [mockToken1.address, mockToken2.address]); // Adjust args as necessary
    console.log(`ERC4626Vault deployed at: ${erc4626Vault.address}`);

    // Deploy UniswapV2Router contract (if you have it)
    const uniswapRouter = await deploy("UniswapV2Router", []); // Adjust args as necessary
    console.log(`UniswapV2Router deployed at: ${uniswapRouter.address}`);

    // Deploy Strategy contract
    const strategy = await deploy("Strategy", [
      erc4626Vault.address,
      uniswapRouter.address,
      customStaking.address,
      rewardToken.address,
      mockToken1.address,
      mockToken2.address
    ]);
    console.log(`Strategy deployed at: ${strategy.address}`);
  } catch (e) {
    console.error(`Error during deployment: ${e.message}`);
  }
})();
