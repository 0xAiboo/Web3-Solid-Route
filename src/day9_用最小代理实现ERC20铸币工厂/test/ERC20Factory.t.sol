// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Factory} from "../src/ERC20Factory.sol";
import {Base20Implementation} from "../src/Base20Implementation.sol";

contract ERC20FactoryTest is Test {
    Base20Implementation bi;
    ERC20Factory factory;
    // 721 Owner
    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address token;
    // 运行测试前的执行代码，可用于准备测试数据
    function setUp() public {
        vm.startPrank(alice);
        bi = new Base20Implementation();
        // bi.initialize("aa", 1000, 100, 1000);
        factory = new ERC20Factory();
        factory.setErc20Implementation(address(bi));
    }
    function test_deployInscription() public {
        deployInscription();
    }
    function deployInscription() private {
        string memory symbol = "AA";
        uint totalSupply = 1000;
        uint perMint = 100;
        uint price = 1000;
        token = factory.deployInscription(symbol, totalSupply, perMint, price);
    }
    function test_mintInscription() public {
        deployInscription();
        mintInscription();
    }
    function mintInscription() private {
        // vm.startPrank(tom);
        // vm.deal(tom, 10 ether);
        uint256 p = Base20Implementation(token).priceOfOne();

        for (uint256 i = 0; i < 10; i++) {
            address randomAddress = vm.addr(i+1);
            vm.startPrank(randomAddress);
            vm.deal(randomAddress, 10 ether);
            factory.mintInscription{value: p}(address(token));
        }

        // factory.mintInscription{value: p}(address(token));
        // factory.mintInscription{value: p}(address(token));
        factory.getBalance();
    }
}
