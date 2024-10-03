// ./ignition/modules/ERC4626VaultModule.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { config } from "dotenv";

config();

const ERC4626VaultModule = buildModule("ERC4626VaultModule", (m) => {
  const token0 = m.getParameter("token0", process.env.A_TOKEN_ADDRESS);
  const token1 = m.getParameter("token1", process.env.B_TOKEN_ADDRESS);


  const vault = m.contract("ERC4626Vault", [token0, token1]);

  return { vault };
});

export default ERC4626VaultModule;
