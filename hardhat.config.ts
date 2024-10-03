import { HardhatUserConfig } from 'hardhat/config'
import '@nomiclabs/hardhat-ethers'
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-ignition";


const config: HardhatUserConfig = {
  solidity: "0.8.20", // Or the specific version your contracts require
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
}

export default config
