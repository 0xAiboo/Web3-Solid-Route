// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface INBTStake {
    struct Stake {
        uint256 amount;
        uint256 lastUpdate;
        uint256 extracted;
    }
    error ErrorAmountThanZero(address user, uint256 amount);
    error ErrorAmountEnghout(address user, uint256 amount);

    event StakeOrder(address user, uint256 amount, uint256 total);
    event unStakeOrder(address user, uint256 amount, uint256 total);
    event claimOrder(address user, uint256 amount, uint256 total);
}
