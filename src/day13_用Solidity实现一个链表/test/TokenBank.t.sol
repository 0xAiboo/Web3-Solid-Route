// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {NBToken} from "../src/NBToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract TokenBankTest is Test {
    using Strings for uint256;
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address owner = makeAddr("owner");
    NBToken nt;
    TokenBank tb;
    uint256 amount = 100 * 1e18;
    uint256 top = 10;
    string[] strList = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];

    function setUp() public {
        vm.startPrank(alice);
        nt = new NBToken();
        tb = new TokenBank();
        vm.stopPrank();
    }
    function test_deposit() public {
        for (uint256 i = 0; i < top; i++) {
            address randUser = makeAddr(strList[i]);
            uint256 _amount = generateRandomNumber(i) * 1e18;
            vm.startPrank(alice);
            nt.transfer(randUser, _amount);
            vm.stopPrank();

            vm.startPrank(randUser);
            nt.approve(address(tb), _amount);
            tb.deposit(address(nt), _amount);
            vm.stopPrank();
        }
        vm.startPrank(alice);
        nt.approve(address(tb), 10_000_000 * 1e18);
        tb.deposit(address(nt), 10_000_000 * 1e18);

        vm.stopPrank();

        address[] memory rank = tb.getTop(address(nt), top);
        assertEq(address(alice), rank[0], "rank Error");
    }

    function test_withdraw() public {
        test_deposit();
         vm.startPrank(alice);
        tb.withdraw(address(nt), 10_000_000 * 1e18);
        address[] memory rank = tb.getTop(address(nt), 11);
        assertEq(address(alice), rank[10], "rank Error");

        vm.stopPrank();
    }
    function generateRandomNumber(uint256 i) private view returns (uint256) {
        // 使用当前块的难度和时间戳作为种子
        uint256 seed = uint256(keccak256(abi.encodePacked(i,block.difficulty, block.timestamp)));

        // 使用 modulus 运算来限制范围为 1 到 1000
        return (seed % 1000) + 1;
    }
    function testFuzz_SetNumber(uint256 x) public {}
}
