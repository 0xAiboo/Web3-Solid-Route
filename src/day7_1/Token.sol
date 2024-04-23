// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10**18;
        balances[msg.sender] = totalSupply;
    }

    modifier enoughMoney(uint256 price) {
        require(
            balances[msg.sender] >= price,
            "ERC20: transfer amount exceeds balance"
        );
        _;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        enoughMoney(_value)
        returns (bool success)
    {
        // write your code here

        balances[_to] += _value;
        balances[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            allowances[_from][msg.sender] >= _value,
            "ERC20: transfer amount exceeds allowance"
        );
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        // write your code here
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
        // write your code here
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(addr)
        }

        return size > 0;
    }

    function safeTansfer(
        address contractAddress,
        address _to,
        uint256 _value
    ) public enoughMoney(_value) returns (bool transferStatus) {
        if (isContract(_to)) {
            (bool success, bytes memory data) = contractAddress.call(
                abi.encodeWithSignature(
                    "tokensReceived(address,address,_value)",
                    msg.sender,
                    _to,
                    _value
                )
            );
            bool result = abi.decode(data, (bool));

            if (result) {
                balances[_to] += _value;
                balances[msg.sender] -= _value;
                emit Transfer(msg.sender, _to, _value);
                return true;
            }else{
                return false;
            }
        } else {
            emit Transfer(msg.sender, _to, _value);

            return transfer(_to, _value);
        }

    }
}
