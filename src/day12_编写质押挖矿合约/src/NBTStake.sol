// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";

import "./interface/INBTStake.sol";
import "./ESNBToken.sol";

// # 编写一个质押挖矿合约，实现如下功能：
// ## 1,用户随时可以质押项目方代币 RNT(自定义的ERC20) ，开始赚取项目方Token(esRNT)；
// ## 2,可随时解押提取已质押的 RNT；
// ## 3,可随时领取esRNT奖励，每质押1个RNT每天可奖励 1 esRNT;
// ## 4,esRNT 是锁仓性的 RNT， 1 esRNT 在 30 天后可兑换 1 RNT，随时间线性释放，支持提前将 esRNT 兑换成 RNT，但锁定部分将被 burn 燃烧掉。

contract NBTStake is INBTStake {
    // uint256 rate = (1e18 * 1) / 1 days;
    uint256 public constant rate = (1 * 1e18) / uint256(1 days);
    IERC20 public immutable NBTOKEN;
    ESNBToken public immutable ESNBTOKEN;
    mapping(address => Stake) stakeList;
    uint256 totalStake;
    constructor(address nb_, address esnb_) {
        NBTOKEN = IERC20(nb_);
        ESNBTOKEN = ESNBToken(esnb_);
    }
    modifier calculate() {
        Stake memory _stake = stakeList[msg.sender];
        uint256 _time = block.timestamp - _stake.lastUpdate;
        uint256 money = ((_stake.amount) * _time * rate);
        _stake.extracted += money;
        _stake.lastUpdate = block.timestamp;
        stakeList[msg.sender] = _stake;
        _;
    }
    function stake(uint256 amount) external calculate {
        if (amount <= 0) revert ErrorAmountThanZero(msg.sender, amount);
        NBTOKEN.transferFrom(msg.sender, address(this), amount);
        stakeList[msg.sender].amount += amount;
        totalStake += amount;
        emit StakeOrder(msg.sender, amount, stakeList[msg.sender].amount);
    }
    function unStake(uint256 amount) external calculate {
        if (amount <= 0) revert ErrorAmountThanZero(msg.sender, amount);
        if (stakeList[msg.sender].amount < amount)
            revert ErrorAmountEnghout(msg.sender, amount);
        NBTOKEN.transfer(msg.sender, amount);
        // address(NBTOKEN).call(
        //     abi.encodeWithSignature(
        //         "transferFrom(address,address,uint256)",
        //         address(this),
        //         msg.sender,
        //         amount
        //     )
        // );
        stakeList[msg.sender].amount -= amount;
        totalStake -= amount;
        emit unStakeOrder(msg.sender, amount, stakeList[msg.sender].amount);
    }
    function claim(uint256 amount) external calculate {
        if (amount <= 0) revert ErrorAmountThanZero(msg.sender, amount);
        if (stakeList[msg.sender].extracted < amount)
            revert ErrorAmountEnghout(msg.sender, amount);
        // ESNBTOKEN.transferFrom(address(this), msg.sender, amount);
        ESNBTOKEN.mint(msg.sender, amount);

        stakeList[msg.sender].extracted -= amount;
        emit unStakeOrder(msg.sender, amount, stakeList[msg.sender].extracted);
    }
    function exchange(uint256 amount) external {
        (uint256 expired, uint256 notExpired) = ESNBTOKEN.balanceOfLock(
            msg.sender
        );
        if (amount > expired + notExpired)
            revert ErrorAmountEnghout(msg.sender, amount);
        if (expired >= amount) {
            NBTOKEN.transfer(msg.sender, amount);
            ESNBTOKEN.burn(msg.sender, amount);
            return;
        } else if (amount > expired) {
            uint256 totalAmount = expired;
            uint256 notEU = ((amount - expired) * 10) / 100;
            uint256 notBU = ((amount - expired) * 90) / 100;
            totalAmount += notEU;
            NBTOKEN.transfer(msg.sender, totalAmount);
            ESNBTOKEN.burn(msg.sender, notBU);
            return;
        }
    }
    function stakeOf(address _user) external view returns (uint256) {
        return stakeList[_user].amount;
    }
    function extractedOf(address _user) external view returns (uint256) {
        return stakeList[_user].extracted;
    }
}
