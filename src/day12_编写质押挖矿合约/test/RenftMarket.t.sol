// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SigUtils} from "./utils/SigUtils.sol";
import {RenftMarket} from "../src/RenftMarket.sol";
import {IRenftMarket} from "../src/interface/IRenftMarket.sol";
import {NFTFactory, S2NFT} from "../src/NFTFactory.sol";
import {Signature} from "../src/utils/Signature.sol";

contract RenftMarketTest is Test {
    struct RentoutOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 daily_rent; // 每日租金
        uint256 max_rental_duration; // 最大租赁时长
        uint256 min_collateral; // 最小抵押
        uint256 list_endtime; // 挂单结束时间
    }
    SigUtils internal sigUtils = new SigUtils();

    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;
    address tom = vm.addr(buyerPrivateKey);
    address owner = makeAddr("owner");
    RenftMarket renft;
    NFTFactory factory;
    address nft;
    S2NFT s2;
    function setUp() public {
        vm.startPrank(alice);
        renft = new RenftMarket();
        factory = new NFTFactory();
        nft = factory.deployNFT("aa", "aa", "aa", 100);
        s2 = S2NFT(nft);
        s2.freeMint(2);
        s2.approve(address(renft), 1);

        vm.stopPrank();
    }
    function test_cancel() public {
        //取消后在进行购买
        uint256 tokenId = 1;
        vm.deal(tom, 10 ether);
        vm.startPrank(alice);
        SigUtils.RentoutOrder memory _rentout = SigUtils.RentoutOrder(
            address(alice),
            nft,
            tokenId,
            1 ether,
            10 days,
            5 ether,
            block.timestamp + 5 days
        );
        bytes32 digest = sigUtils.getTypedDataHash(_rentout);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        bytes memory _sign = Signature.fromVRS(v, r, s);
        renft.cancelOrder(
            IRenftMarket.RentoutOrder(
                address(alice),
                nft,
                tokenId,
                1 ether,
                10 days,
                5 ether,
                block.timestamp + 5 days
            ),
            _sign
        );
        test_borrow();
    }
    function test_borrow() public {
        uint256 tokenId = 1;
        vm.deal(tom, 10 ether);
        vm.startPrank(tom);
        SigUtils.RentoutOrder memory _rentout = SigUtils.RentoutOrder(
            address(alice),
            nft,
            tokenId,
            1 ether,
            10 days,
            5 ether,
            block.timestamp + 5 days
        );
        bytes32 digest = sigUtils.getTypedDataHash(_rentout);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        bytes memory _sign = Signature.fromVRS(v, r, s);
        renft.borrow{value: 10 ether}(
            IRenftMarket.RentoutOrder(
                address(alice),
                nft,
                tokenId,
                1 ether,
                10 days,
                5 ether,
                block.timestamp + 5 days
            ),
            _sign
        );
        // SigUtils.Permit memory permit = SigUtils.Permit(_rentout);
        // renft.borrow(_rentout);
        vm.stopPrank();
    }

    function testFuzz_SetNumber(uint256 x) public {}
}
