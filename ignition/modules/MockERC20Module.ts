import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "hardhat";
import { config } from "dotenv";

config();


const MockERC20Module = buildModule("MockERC20Module", (m) => {
  console.log(`Owner Address: ${process.env.OWNER_ADDRESS}`);
  const lpTokenAddress=process.env.LP_TOKEN_ADDRESS;
  const rewardTokenAddress=process.env.REWARD_TOKEN_ADDRESS;
  const tokenAAddress=process.env.TOKEN_A_ADDRESS
  const tokenBAddress=process.env.TOKEN_B_ADDRESS
  const ownerAddress=process.env.OWNER_ADDRESS;
  const feeToSetterAddress=process.env.FEE_TO_SETTER_ADDRESS;

  const tokenA = m.contract("MockERC20", ["TokenA", "TKA", 18, m.getParameter("initialSupply", 1000000000), m.getParameter("ownerAddress", process.env.OWNER_ADDRESS)], { id: process.env.MOCKERCTOKEN_A });
  const tokenB = m.contract("MockERC20", ["TokenB", "TKB", 18, m.getParameter("initialSupply", 1000000000), m.getParameter("ownerAddress", process.env.OWNER_ADDRESS)], { id: process.env.MOCKERCTOKEN_B });
  const lpToken = m.contract("MockERC20", ["LP Token", "LPT", 18, m.getParameter("initialSupply", 1000000000), m.getParameter("ownerAddress", process.env.OWNER_ADDRESS)], { id: process.env.MOCKERCTOKEN_LP });
  const rewardToken = m.contract("MockERC20", ["RewardToken", "RWD", 18, m.getParameter("initialSupply", 1000000000), m.getParameter("ownerAddress", process.env.OWNER_ADDRESS)], { id: process.env.MOCKERCTOKEN_REWARD });


  const customStaking = m.contract("CustomStaking", [lpTokenAddress, rewardTokenAddress]);

  const erc4626Vault = m.contract("ERC4626Vault", [tokenAAddress, tokenBAddress]);

  const uniswapFactory = m.contract("UniswapV2Factory", [m.getParameter("feeToSetter", process.env.FEE_TO_SETTER_ADDRESS), m.getParameter("ownerAddress", process.env.OWNER_ADDRESS)]);

  const uniswapRouter = m.contract("UniswapV2Router", [uniswapFactory]);

  const strategy = m.contract("Strategy", [
    erc4626Vault.from,
    uniswapRouter.from,
    customStaking.from,
    rewardToken.from,
    tokenA.from,
    tokenB.from
  ]);


  return { tokenA, tokenB, rewardToken, lpToken };
});

export default MockERC20Module;
