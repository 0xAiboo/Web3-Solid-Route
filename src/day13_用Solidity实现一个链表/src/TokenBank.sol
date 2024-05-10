// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "./interface/TokensReceive.sol";
// import {Base20Token} from "./Base20Token.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {console} from "forge-std/Test.sol";

contract TokenBank is TokensReceive {
    ERC20Permit erc20;
    mapping(address => mapping(address => uint256)) balances;
    mapping(address => mapping(address => address)) next;
    address constant GUARD = address(1);
    uint256 listSize = 0;
    function _addNewDepositUser(
        address contractAddress,
        uint256 _value
    ) internal {
        require(
            next[contractAddress][msg.sender] == address(0),
            "user is already"
        );
        if (next[contractAddress][GUARD] == address(0))
            next[contractAddress][GUARD] = GUARD;
        address index = _findIndex(contractAddress, _value);
        console.log(index);
        next[contractAddress][msg.sender] = next[contractAddress][index];
        next[contractAddress][index] = msg.sender;
        listSize++;
    }

    function deposit(address contractAddress, uint256 _value) public {
        erc20 = ERC20Permit(contractAddress);
        erc20.transferFrom(msg.sender, address(this), _value);
        balances[contractAddress][msg.sender] += _value;
        if (_isNewUser(contractAddress)) {
            _addNewDepositUser(contractAddress, _value);
        } else {
            _updateRank(contractAddress);
        }
    }
    function _isNewUser(address contractAddress) internal view returns (bool) {
        return next[contractAddress][msg.sender] == address(0);
    }
    function getTop(
        address contractAddress,
        uint256 _size
    ) public view returns (address[] memory) {
        address beginAddress = GUARD;
        address[] memory list = new address[](_size);
        for (uint256 i = 0; i < _size; i++) {
            address userAddress = next[contractAddress][beginAddress];
            // list.push(userAddress);
            list[i] = userAddress;
            if (next[contractAddress][userAddress] == GUARD) return list;
            beginAddress = userAddress;
        }
        return list;
    }
    function _updateRank(address contractAddress) internal {
        require(
            next[contractAddress][msg.sender] != address(0),
            "user is exits"
        );

        address _preIndex = _findPreIndex(contractAddress);
        address _nextIndex = next[contractAddress][msg.sender];
        uint256 _newAmount = balances[contractAddress][msg.sender];
        if (!_verifyIndex(contractAddress, _preIndex, _newAmount, _nextIndex)) {
            _removeUser(contractAddress, _preIndex, _nextIndex);
            _addNewDepositUser(contractAddress, _newAmount);
        }
    }
    function _removeUser(
        address contractAddress,
        address _preIndex,
        address _nextIndex
    ) internal {
        require(next[contractAddress][msg.sender] != address(0));
        next[contractAddress][_preIndex] = _nextIndex;
        next[contractAddress][msg.sender] = address(0);
        listSize--;
    }
    function _findPreIndex(address contractAddress) internal returns (address) {
        address beginAddress = GUARD;
        while (next[contractAddress][beginAddress] != GUARD) {
            if (next[contractAddress][beginAddress] == msg.sender)
                return beginAddress;
            beginAddress = next[contractAddress][beginAddress];
        }
        return address(0);
    }
    function _findIndex(
        address contractAddress,
        uint256 _newValue
    ) internal view returns (address) {
        address _beginAddress = GUARD;
        while (true) {
            if (
                _verifyIndex(
                    contractAddress,
                    _beginAddress,
                    _newValue,
                    next[contractAddress][_beginAddress]
                )
            ) return _beginAddress;
            _beginAddress = next[contractAddress][_beginAddress];
        }
    }
    function _verifyIndex(
        address contractAddress,
        address _prev,
        uint256 _newValue,
        address _next
    ) internal view returns (bool) {
        return
            (_prev == GUARD || balances[contractAddress][_prev] >= _newValue) &&
            (_next == GUARD || balances[contractAddress][_next] < _newValue);
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
        ERC20Permit(contractAddress).permit(
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

    function withdraw(address contractAddress, uint256 _value) public {
        erc20 = ERC20Permit(contractAddress);
        erc20.transfer(msg.sender, _value);
        balances[contractAddress][msg.sender] -= _value;
        _updateRank(contractAddress);
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
