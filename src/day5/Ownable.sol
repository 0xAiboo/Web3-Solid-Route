// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

import "./BigBank.sol";

contract Ownable {
    address public bigBankContract;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    function setBigBankContractAddress(address _bigBankContract)
        public
        onlyOwner
    {
        require(_bigBankContract != address(0), "_storageContract error");
        bigBankContract = _bigBankContract;
    }

    function withdrawBigBank(address _to, uint256 amount) public onlyOwner {
        (bool success, bytes memory result) = bigBankContract.call(
            abi.encodeWithSignature("withdraw(address,uint256)", _to, amount)
        );
        require(success, "delegatecall failed");
    }
}
