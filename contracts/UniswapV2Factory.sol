// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./UniswapV2Pair.sol"; // Assuming UniswapV2Pair.sol is in the same directory
import "@openzeppelin/contracts/access/Ownable.sol";

contract UniswapV2Factory is Ownable {
    address public feeTo;
    address public feeToSetter;
    address public ownerAddress;

    // Mapping to store all created pairs and their address
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    constructor(address _feeToSetter,address _ownerAddress) Ownable(_ownerAddress) {
        feeToSetter = _feeToSetter;
        ownerAddress = _ownerAddress;
    }

    /// @notice Creates a pair for two tokens and returns the address of the pair contract
    /// @dev Reverts if the pair already exists.
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        require(tokenA != address(0) && tokenB != address(0), "UniswapV2: ZERO_ADDRESS");
        require(getPair[tokenA][tokenB] == address(0), "UniswapV2: PAIR_EXISTS");

        // Sort the tokens by address to ensure consistency
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        // Deploy the pair contract using a factory pattern
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        UniswapV2Pair(pair).initialize(token0, token1);

        // Store the pair in the mapping
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // Ensure both mappings are valid
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /// @notice Returns the number of created pairs
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    /// @notice Sets the fee receiver address
    function setFeeTo(address _feeTo) external onlyOwner {
        feeTo = _feeTo;
    }

    /// @notice Sets the fee setter address (who can update the fee receiver)
    function setFeeToSetter(address _feeToSetter) external onlyOwner {
        feeToSetter = _feeToSetter;
    }
}
