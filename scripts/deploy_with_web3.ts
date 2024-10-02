import Web3 from './web3-lib'
import { Contract, ContractSendMethod, Options } from 'web3-eth-contract'

const web3Provider = 'http://localhost:8545'; // Replace with your provider if necessary

/**
 * Deploy the given contract
 * @param {string} contractName - Name of the contract to deploy
 * @param {Array<any>} args - List of constructor parameters
 * @param {string} from - Account used to send the transaction
 * @param {number} gas - Gas limit
 * @return {Options} - Deployed contract options
 */
export const deploy = async (contractName: string, args: Array<any>, from?: string, gas?: number): Promise<Options> => {
    const web3 = new Web3(web3Provider)
    console.log(`Deploying ${contractName}`)

    const artifactsPath = `browser/contracts/artifacts/${contractName}.json`
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

    const accounts = await web3.eth.getAccounts()
    const contract: Contract = new web3.eth.Contract(metadata.abi)

    const contractSend: ContractSendMethod = contract.deploy({
        data: metadata.data.bytecode.object,
        arguments: args
    })

    const newContractInstance = await contractSend.send({
        from: from || accounts[0],
        gas: gas || 1500000
    })

    return newContractInstance.options
}

(async () => {
    try {
        // Deploy ERC20 Mock Tokens (if needed)
        const mockToken1 = await deploy('MockERC20', ['TokenA', 'TKA', 18, '1000000000000000000000']) // Initial supply for TokenA
        console.log(`TokenA deployed at: ${mockToken1.address}`)

        const mockToken2 = await deploy('MockERC20', ['TokenB', 'TKB', 18, '1000000000000000000000']) // Initial supply for TokenB
        console.log(`TokenB deployed at: ${mockToken2.address}`)

        // Deploy reward token
        const rewardToken = await deploy('MockERC20', ['RewardToken', 'RWD', 18, '1000000000000000000000']) // Initial supply for RewardToken
        console.log(`RewardToken deployed at: ${rewardToken.address}`)

        // Deploy CustomStaking contract
        const customStaking = await deploy('CustomStaking', [mockToken1.address, rewardToken.address])
        console.log(`CustomStaking deployed at: ${customStaking.address}`)

        // Deploy ERC4626Vault contract (if you have it)
        const erc4626Vault = await deploy('ERC4626Vault', []) // Adjust args as necessary
        console.log(`ERC4626Vault deployed at: ${erc4626Vault.address}`)

        // Deploy UniswapV2Router contract (if you have it)
        const uniswapRouter = await deploy('UniswapV2Router', []) // Adjust args as necessary
        console.log(`UniswapV2Router deployed at: ${uniswapRouter.address}`)

        // Deploy Strategy contract
        const strategy = await deploy('Strategy', [
            erc4626Vault.address,
            uniswapRouter.address,
            customStaking.address,
            rewardToken.address,
            mockToken1.address,
            mockToken2.address
        ])
        console.log(`Strategy deployed at: ${strategy.address}`)
    } catch (e) {
        console.error(`Error during deployment: ${e.message}`)
    }
})()
