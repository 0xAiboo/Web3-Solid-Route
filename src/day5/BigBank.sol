// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;
import "./Bank.sol";
import "./Ownable.sol";

contract BigBank is Bank, Ownable {
    error lessThanPayable(string);
    error notOwner(string);
    uint256 public withdrawCount;

    function transferOwner(address _newO) public onlyOwner {
        if (msg.sender != owner) revert("you are not owner");
        owner = _newO;
    }

    modifier greaterThanMinDeposit() {
        if (msg.value < 1e15) revert lessThanPayable("less than 0.001 ether");
        _;
    }

    function withdraw(address _to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        withdrawCount += 1;
        require(
            address(this).balance >= amount,
            "Insufficient contract balance"
        );
        payable(_to).transfer(amount);
        return true;
    }

    receive() external payable override greaterThanMinDeposit {
        super.depositMoney();
    }
}
