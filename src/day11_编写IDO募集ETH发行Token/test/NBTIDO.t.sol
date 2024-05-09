// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {NBTIDO} from "../src/NBTIDO.sol";
import {NBToken} from "../src/NBToken.sol";
import {INBTIDO} from "../src/interface/INBTIDO.sol";

contract NBTIDOTest is Test {
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address owner = makeAddr("owner");
    NBTIDO ido;
    NBToken nt;

    function setUp() public {
        vm.startPrank(alice);
        ido = new NBTIDO();
        nt = new NBToken();
        vm.stopPrank();
    }
    function test_addToken() public {
        vm.startPrank(alice);

        INBTIDO.IDOProject memory _project = INBTIDO.IDOProject(
            address(alice),
            0.001 ether,
            1 ether,
            10 ether,
            block.timestamp + 1 days,
            10000
        );
        nt.approve(address(ido), 10000 ether);
        ido.addIDOProject(address(nt), _project);
        vm.stopPrank();
    }
    function test_preSale() public {
        test_addToken();
        vm.startPrank(tom);
        vm.deal(tom, 100 ether);
        ido.preSale{value: 1 ether}(address(nt));
        assertEq(
            ido._preSaleOfMe(address(nt)),
            1 ether,
            "expect per-sale amount"
        );
        assertEq(
            ido._projectAmount(address(nt)),
            1 ether,
            "expect project amount"
        );
        vm.stopPrank();
    }

    function test_refund() public {
        test_preSale();
        vm.startPrank(tom);
        vm.warp(block.timestamp + 2 days);
        ido.refund(address(nt));

        assertEq(address(tom).balance, 100 ether, "expect refund user");
        vm.stopPrank();

        vm.startPrank(alice);
        ido.refund(address(nt));
        assertEq(
            nt.balanceOf(address(alice)),
            21_000_000 * 1e18,
            "expect refund owner"
        );

        vm.stopPrank();
    }
    function test_claim() public {
        test_preSale();
        vm.startPrank(tom);
        vm.warp(block.timestamp + 2 days);
        ido.claim(address(nt));
        assertEq(
            nt.balanceOf(address(tom)),
            1 ether / 0.001 ether,
            "expect claim token user"
        );
        // assertEq(address(tom).balance, 100 ether, "expect refund user");
        vm.stopPrank();

        vm.startPrank(alice);
        ido.claim(address(nt));
        assertEq(
            address(alice).balance,
            1 ether,
            "expect claim eth owner"
        );

        vm.stopPrank();
    }
    function testFuzz_SetNumber(uint256 x) public {}
}
