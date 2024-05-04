// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {Base20Token} from "../src/Base20Token.sol";
import {SigUtils} from "./utils/SigUtils.sol";
contract TokenBankTest is Test {
    Base20Token usdt;
    TokenBank bank;
    SigUtils internal sigUtils;
    uint256 internal ownerPrivateKey;
    address internal owner;
    uint256 internal total = 1e10 * 1e18;
    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);
        vm.startPrank(owner);
        usdt = new Base20Token("Teg", "USDT", total);
        bank = new TokenBank();
        sigUtils = new SigUtils(usdt.DOMAIN_SEPARATOR());
        vm.stopPrank();
    }
    function test_depositUSDTPermit() public {
        uint256 price = 1000;
        depositUSDTPermit(price);
    }

    function depositUSDTPermit(uint _value) private {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(bank),
            value: _value,
            nonce: usdt.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        vm.startPrank(owner);
        bank.permitDeposit(
            address(usdt),
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
        assertEq(
            bank.bankBalance(address(usdt)),
            _value,
            "deposit money exception"
        );
        assertEq(
            usdt.balanceOf(owner),
            total - _value,
            "deposit money exception"
        );
    }
}
