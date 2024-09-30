// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC4626Vault.sol";
import "./UniswapV2Router.sol";
import "./CustomStaking.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Strategy {
    using SafeERC20 for IERC20;

    ERC4626Vault public vault;
    UniswapV2Router public router;
    CustomStaking public stakingContract;
    IERC20 public rewardToken;

    address public immutable tokenA;
    address public immutable tokenB;

    constructor(
        address _vault,
        address _router,
        address _stakingContract,
        address _rewardToken,
        address _tokenA,
        address _tokenB
    ) {
        vault = ERC4626Vault(_vault);
        router = UniswapV2Router(_router);
        stakingContract = CustomStaking(_stakingContract);
        rewardToken = IERC20(_rewardToken);
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    /// @notice Deposit assets into the vault, provide liquidity to Uniswap V2, and stake the resulting LP tokens
    function deposit(uint256 amountA, uint256 amountB) external {
        // Transfer tokens from user to the strategy
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // Approve Uniswap Router to spend tokens
        IERC20(tokenA).approve(address(router), amountA);
        IERC20(tokenB).approve(address(router), amountB);

        // Add liquidity to Uniswap V2 and receive LP tokens
        (uint256 amountDepositedA, uint256 amountDepositedB, uint256 liquidity) = router.addLiquidity(tokenA, tokenB, amountA, amountB);

        // Mint shares to the user using ERC4626 vault
        vault.deposit(liquidity, msg.sender);

        // Approve staking contract to spend LP tokens
        IERC20(vault.totalAssets()()).approve(address(stakingContract), liquidity);

        // Stake LP tokens in the staking contract
        stakingContract.stake(liquidity);
    }

    /// @notice Withdraw assets from the vault, unstake LP tokens, and remove liquidity from Uniswap V2
    function withdraw(uint256 shares) external {
        // Burn shares in the vault and get proportional LP tokens
        uint256 lpTokens = vault.withdraw(shares, msg.sender);

        // Unstake LP tokens from the staking contract
        stakingContract.unstake(lpTokens);

        // Approve Uniswap router to remove liquidity
        IERC20(vault.totalAssets()).approve(address(router), lpTokens);

        // Remove liquidity from Uniswap V2
        (uint256 amountA, uint256 amountB) = router.removeLiquidity(tokenA, tokenB, lpTokens);

        // Transfer the underlying tokens back to the user
        IERC20(tokenA).safeTransfer(msg.sender, amountA);
        IERC20(tokenB).safeTransfer(msg.sender, amountB);
    }

    /// @notice View function to get user’s reward
    function getUserRewards(address user) external view returns (uint256) {
        uint256 userShares = vault.balanceOf(user);
        uint256 totalShares = vault.totalSupply();

        uint256 stakedAmount = stakingContract.balanceOf(address(this));
        uint256 totalRewards = stakingContract.getTotalRewards();

        // Calculate the user's share of the rewards based on vault shares
        return (userShares * totalRewards) / totalShares;
    }

    /// @notice Allow users to claim their accrued rewards
    function claimRewards() external {
        // Fetch the user’s share of the rewards
        uint256 userRewards = getUserRewards(msg.sender);

        // Distribute rewards to the user
        rewardToken.safeTransfer(msg.sender, userRewards);
    }

    /// @notice Reinvest rewards into the Uniswap V2 pool and mint more shares to users
    function reinvestRewards() external {
        // Claim the accrued rewards
        uint256 rewards = stakingContract.claimRewards();

        // Split rewards into tokenA and tokenB
        address;
        path[0] = address(rewardToken);
        path[1] = tokenA; // Assume reward token can be swapped for tokenA

        rewardToken.approve(address(router), rewards);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            rewards,
            0,  // No minimum output
            path
        );

        uint256 swappedA = amounts[1];
        uint256 swappedB = rewards - swappedA; // Simplified logic for splitting into A and B

        // Add liquidity to Uniswap V2
        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity(tokenA, tokenB, swappedA, swappedB);

        // Mint shares to the user using ERC4626 vault
        vault.deposit(liquidity, msg.sender);
    }
}
