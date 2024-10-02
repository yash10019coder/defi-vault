// Import web3 library
import Web3 from 'web3';

// Initialize web3 instance
const web3 = new Web3(Web3.givenProvider || 'http://localhost:8545');

// ABI and bytecode for the contracts (replace with your actual ABI and bytecode)
const storageABI = [ /* ABI array for Storage contract */ ];
const storageBytecode = '0x...'; // Bytecode of Storage contract

const vaultABI = [ /* ABI array for ERC4626Vault contract */ ];
const vaultBytecode = '0x...'; // Bytecode of ERC4626Vault contract

const routerABI = [ /* ABI array for UniswapV2Router contract */ ];
const routerBytecode = '0x...'; // Bytecode of UniswapV2Router contract

const stakingABI = [ /* ABI array for CustomStaking contract */ ];
const stakingBytecode = '0x...'; // Bytecode of CustomStaking contract

(async () => {
  try {
    const accounts = await web3.eth.getAccounts();

    // Deploy Storage contract
    const storageContract = new web3.eth.Contract(storageABI);
    const storageInstance = await storageContract
      .deploy({ data: storageBytecode })
      .send({ from: accounts[0], gas: 5000000 });
    
    console.log(`Storage contract deployed at address: ${storageInstance.options.address}`);

    // Deploy ERC4626Vault contract
    const vaultContract = new web3.eth.Contract(vaultABI);
    const vaultInstance = await vaultContract
      .deploy({ data: vaultBytecode })
      .send({ from: accounts[0], gas: 5000000 });
    
    console.log(`ERC4626Vault contract deployed at address: ${vaultInstance.options.address}`);

    // Deploy UniswapV2Router contract
    const routerContract = new web3.eth.Contract(routerABI);
    const routerInstance = await routerContract
      .deploy({ data: routerBytecode })
      .send({ from: accounts[0], gas: 5000000 });
    
    console.log(`UniswapV2Router contract deployed at address: ${routerInstance.options.address}`);

    // Deploy CustomStaking contract
    const stakingContract = new web3.eth.Contract(stakingABI);
    const stakingInstance = await stakingContract
      .deploy({ data: stakingBytecode, arguments: [/* constructor args here */] }) // Add constructor arguments if needed
      .send({ from: accounts[0], gas: 5000000 });
    
    console.log(`CustomStaking contract deployed at address: ${stakingInstance.options.address}`);

    // Optionally, you can save addresses to deploy in a config or use them for further interactions
  } catch (error) {
    console.log("Error deploying contracts:", error.message);
  }
})();
