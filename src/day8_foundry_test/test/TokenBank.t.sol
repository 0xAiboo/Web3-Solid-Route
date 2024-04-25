// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {Base20Token} from "../src/Base20Token.sol";
contract TokenBankTest is Test {
    Base20Token usdt;
    TokenBank bank;
    address alice = makeAddr("alice");
    address tom = makeAddr("tom");
    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(alice);
        usdt = new Base20Token("Teg", "USDT", 1e18);
        bank = new TokenBank();
        vm.stopPrank();
    }
    function test_deposit() public {
        uint256 price = 1000;
        depositUSDT(price);
    }
    function depositUSDT(uint256 _value) private {
        /**
         * 预期错误：转账错误
         *
         */
        vm.startPrank(alice);
        vm.expectRevert("TransferForm failed");
        bank.deposit(address(usdt), _value);

        /**
         * 预期错误：转账错误
         *  余额不足
         */
        vm.startPrank(tom);
        usdt.approve(address(bank), _value);
        vm.expectRevert("TransferForm failed");
        bank.deposit(address(usdt), _value);

        vm.startPrank(alice);
        usdt.approve(address(bank), _value);
        bank.deposit(address(usdt), _value);
        assertEq(bank.bankBalance(address(usdt)), 1000, "deposit success");
        assertEq(usdt.balanceOf(alice), 1e18 - 1000, "deposit success");
        vm.stopPrank();
    }
    function test_withdraw() public {
        uint256 price = 1000;
        depositUSDT(price);
        withdrawUSDT(price);
    }
    function withdrawUSDT(uint256 _value) private {
        /**
         * 预期错误：存款金额不足
         *
         */
        vm.startPrank(tom);
        vm.expectRevert("Insufficient account balance");
        bank.withdraw(address(usdt), _value);

        vm.startPrank(alice);
        bank.withdraw(address(usdt), _value);
    }

    function test_depositCallBack() public {
        uint256 price = 1000;
        depositUSDTCallback(price);
    }
    function depositUSDTCallback(uint256 _value) private {
        /**
         * 预期错误：转账错误
         *余额不足
         */
        vm.startPrank(tom);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientBalance(address,uint256,uint256)",
                address(tom),
                0,
                _value
            )
        );
        usdt.transferWithCallback(address(bank), _value, "");

        vm.startPrank(alice);
        usdt.transferWithCallback(address(bank), _value, "");
        assertEq(bank.bankBalance(address(usdt)), 1000, "deposit success");
        assertEq(usdt.balanceOf(alice), 1e18 - 1000, "deposit success");
        vm.stopPrank();
    }
}
