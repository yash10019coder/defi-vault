// ./ignition/modules/UniswapV2RouterModule.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { config } from "dotenv";

config();

const UniswapV2RouterModule = buildModule("UniswapV2RouterModule", (m) => {
  const router = m.contract("UniswapV2Router");

  return { router };
});

export default UniswapV2RouterModule;
