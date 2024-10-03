import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { config } from "dotenv";

config();



const CustomStakingModule = buildModule("CustomStakingModule", (m) => {
  const lpToken = m.getParameter("lpToken", process.env.LP_TOKEN_ADDRESS);
  const rewardToken = m.getParameter("rewardToken", process.env.REWARD_TOKEN_ADDRESS);

  const customStaking = m.contract("CustomStaking", [lpToken, rewardToken]);

  return { customStaking };
});

export default CustomStakingModule;
