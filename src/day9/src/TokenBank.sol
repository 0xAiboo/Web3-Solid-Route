// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "./interface/TokensReceive.sol";
import {Base20Token} from "./Base20Token.sol";

contract TokenBank is TokensReceive {
    mapping(address => mapping(address => uint256)) balances;

    function deposit(
        address contractAddress,
        uint256 _value
    ) public returns (bool) {
        (bool successTransferForm, ) = contractAddress.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                this,
                _value
            )
        );
        require(successTransferForm, "TransferForm failed");

        balances[contractAddress][msg.sender] += _value;

        return successTransferForm;
    }

    function permitDeposit(
        address contractAddress,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        Base20Token(contractAddress).permit(
            msg.sender,
            spender,
            amount,
            deadline,
            v,
            r,
            s
        );
        deposit(contractAddress, amount);
    }
    function bankBalance(
        address contractAddress
    ) public view returns (uint256) {
        return balances[contractAddress][msg.sender];
    }

    function withdraw(
        address contractAddress,
        uint256 _value
    ) public returns (bool) {
        uint256 amount = balances[contractAddress][msg.sender];
        require(amount >= _value, "Insufficient account balance");
        (bool successTransfer, ) = contractAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                msg.sender,
                _value
            )
        );
        require(successTransfer, "withdraw failed");
        balances[contractAddress][msg.sender] -= _value;
        return successTransfer;
    }

    function tokensReceive(
        address _from,
        address,
        uint256 _value,
        bytes memory
    ) external returns (bool) {
        balances[msg.sender][_from] += _value;
        return true;
    }
}
