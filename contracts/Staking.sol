// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingContract {
    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public rewardBalances;
    address public strategy;

    modifier onlyStrategy() {
        require(msg.sender == strategy, "Not authorized");
        _;
    }

    constructor(address _strategy) {
        strategy = _strategy;
    }

    function stake(uint256 amount) external onlyStrategy {
        stakedAmounts[msg.sender] += amount;
        // Update staked amounts and reward logic
    }

    function unstake(uint256 amount) external onlyStrategy {
        stakedAmounts[msg.sender] -= amount;
        // Update unstaked amounts and reward logic
    }

    function distributeRewards(uint256 rewards) external onlyStrategy {
        // Reward distribution logic based on user staked amounts
    }
}
