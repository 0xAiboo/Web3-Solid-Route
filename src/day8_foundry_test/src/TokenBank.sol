// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "./interface/TokensReceive.sol";

contract TokenBank is TokensReceive {
    mapping(address => mapping(address => uint256)) balances;

    function deposit(address contractAddress, uint256 _value)
        public
        returns (bool)
    {
        // (bool success, bytes memory data) = contractAddress.call(
        //     abi.encodeWithSignature("balanceOf(address)", msg.sender)
        // );
        // uint256 result = abi.decode(data, (uint256));
        // require(result >= _value, "Insufficient account balance");
        // require(success, "Balance query failed");

        // (bool successAllowance, bytes memory allowanceData) = contractAddress
        //     .call(
        //         abi.encodeWithSignature(
        //             "allowance(address,address)",
        //             msg.sender,
        //             this
        //         )
        //     );
        // uint256 allowance = abi.decode(allowanceData, (uint256));
        // require(allowance >= _value, "Insufficient account allowance");
        // require(successAllowance, "Allowance query failed");

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

    function bankBalance(address contractAddress)
        public
        view
        returns (uint256)
    {
        return balances[contractAddress][msg.sender];
    }

    function withdraw(address contractAddress, uint256 _value)
        public
        returns (bool)
    {
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
