// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {ESNBToken} from "../src/ESNBToken.sol";
import {NBToken} from "../src/NBToken.sol";
import {NBTStake} from "../src/NBTStake.sol";

contract NBTStakeTest is Test {
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address owner = makeAddr("owner");
    NBToken nt;
    ESNBToken esnb;
    NBTStake ns;

    function setUp() public {
        vm.startPrank(alice);
        nt = new NBToken();
        esnb = new ESNBToken();
        ns = new NBTStake(address(nt), address(esnb));
        nt.transfer(tom, 1_000_000 * 1e18);
        vm.stopPrank();
    }
    function test_stake() public {
        uint256 _amount = 10000 * 1e18;
        vm.startPrank(tom);
        nt.approve(address(ns), _amount);
        ns.stake(_amount);
        assertEq(ns.stakeOf(address(tom)), _amount, "stake amount except");
        assertEq(
            nt.balanceOf(address(tom)),
            1_000_000 * 1e18 - _amount,
            "stake amount except"
        );
        vm.stopPrank();
    }
    function test_unStake() public {
        test_stake();
        vm.startPrank(tom);
        ns.unStake(10000 * 1e18);
        assertEq(ns.stakeOf(address(tom)), 0, "stake amount except");
        assertEq(
            nt.balanceOf(address(tom)),
            1_000_000 * 1e18,
            "stake amount except"
        );
        vm.stopPrank();
    }
    function test_claim() public {
        test_stake();
        vm.startPrank(tom);
        uint256 _amount = 10000 * 1e18;
        /**
         *  预期错误：余额不足
         */
        vm.expectRevert(
            abi.encodeWithSignature(
                "ErrorAmountEnghout(address,uint256)",
                address(tom),
                _amount
            )
        );
        ns.claim(_amount);

        vm.warp(block.timestamp + 1 days);

        ns.claim(_amount);
        // assertEq(ns.extractedOf(address(tom)), 0, "except claim");
        assertEq(esnb.balanceOf(address(tom)), _amount, "except claim");

        vm.stopPrank();
    }
    function test_exchange() public {
        test_claim();
        vm.startPrank(tom);
        uint256 _amount = 10000 * 1e18;
        /**
         *  预期错误：余额不足
         */
        vm.expectRevert(
            abi.encodeWithSignature(
                "ErrorAmountEnghout(address,uint256)",
                address(tom),
                _amount * 2
            )
        );

        ns.exchange(_amount * 2);
        ns.exchange(_amount);

        assertEq(
            nt.balanceOf(address(tom)),
            (1_000_000 * 1e18 - _amount) + ((_amount * 10) / 100),
            "Before the staking time is reached, you can only withdraw 10%"
        );
    }

    function test_exchangeEnd() public {
        test_claim();
        vm.startPrank(tom);
        uint256 _amount = 10000 * 1e18;
        /**
         *  预期错误：余额不足
         */
        vm.expectRevert(
            abi.encodeWithSignature(
                "ErrorAmountEnghout(address,uint256)",
                address(tom),
                _amount * 2
            )
        );

        ns.exchange(_amount * 2);
        vm.warp(block.timestamp + 31 days);
        ns.exchange(_amount);
        assertEq(
            nt.balanceOf(address(tom)),
            1_000_000 * 1e18,
            "except LockTime"
        );
    }
    function testFuzz_SetNumber(uint256 x) public {}
}
