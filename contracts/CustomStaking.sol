// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CustomStaking is ReentrancyGuard {
    IERC20 public lpToken;
    IERC20 public rewardToken;
    uint public rewardRate = 100; // Customize the reward rate
    mapping(address => uint) public stakedBalances;
    mapping(address => uint) public rewards;

    constructor(IERC20 _lpToken, IERC20 _rewardToken) {
        lpToken = _lpToken;
        rewardToken = _rewardToken;
    }

    function stake(uint _amount) external nonReentrant {
        require(_amount > 0, "Cannot stake 0");
        lpToken.transferFrom(msg.sender, address(this), _amount);
        stakedBalances[msg.sender] += _amount;
        rewards[msg.sender] = block.timestamp;
    }

    function unstake(uint _amount) external nonReentrant {
        require(stakedBalances[msg.sender] >= _amount, "Insufficient balance to unstake");
        stakedBalances[msg.sender] -= _amount;
        lpToken.transfer(msg.sender, _amount);

        uint reward = calculateReward(msg.sender);
        rewards[msg.sender] = block.timestamp;
        rewardToken.transfer(msg.sender, reward);
    }

    function claimRewards() external nonReentrant {
        uint reward = calculateReward(msg.sender);
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }

    function calculateReward(address _user) public view returns (uint) {
        uint timeStaked = block.timestamp - rewards[_user];
        return stakedBalances[_user] * rewardRate * timeStaked;
    }

    function balanceOf(address _user) external view returns (uint) {
        return stakedBalances[_user];
    }

    function getTotalRewards() external view returns (uint) {
        return rewardToken.balanceOf(address(this));
    }
}
