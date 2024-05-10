// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ESNBToken is ERC20Permit {
    string private constant _name = "ESNBToken";
    string private constant _symbol = "ESNBT";
    struct LockAmount {
        uint256 amount;
        uint256 lockTime;
    }
    // uint256 private constant _total = 21_000_000 * 1e18;
    mapping(address => LockAmount[]) lockMapping;
    constructor() ERC20Permit(_name) ERC20(_name, _symbol) {
        // _mint(msg.sender, _total);
    }
    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
        LockAmount memory _lockAmount = LockAmount(
            _amount,
            block.timestamp + 30 days
        );
        lockMapping[_to].push(_lockAmount);
    }
    function transfer(address, uint256) public pure override returns (bool) {
        return false;
    }
    function transferFrom(
        address,
        address,
        uint256
    ) public pure override returns (bool) {
        return false;
    }
    function balanceOfLock(
        address user
    ) external view returns (uint256 expired, uint256 notExpired) {
        LockAmount[] memory _list = lockMapping[user];

        for (uint256 i = 0; i < _list.length; i++) {
            if (_list[i].lockTime < block.timestamp) {
                expired += _list[i].amount;
            } else {
                notExpired += _list[i].amount;
            }
        }
    }
    function burn(address user, uint256 amount) public {
        LockAmount[] memory _list = lockMapping[user];
        for (uint256 i = 0; i < _list.length; i++) {
            if (_list[i].amount > amount) {
                _list[i].amount -= amount;
                _burn(user, amount);
            } else if (_list[i].amount == amount) {
                deleteArray(i, user);
                _burn(user, amount);
                return;
            } else {
                deleteArray(i, user);
                uint256 lastAmount = amount - _list[i].amount;
                _burn(user, _list[i].amount);
                burn(user, lastAmount);
            }
        }
    }

    function deleteArray(uint256 index, address user) internal {
        LockAmount[] storage _list = lockMapping[user];
        LockAmount memory elementToMove = _list[index];
        // 从要移动的位置开始，依次将后面的元素向前移动一位
        for (uint256 i = index; i < _list.length - 1; i++) {
            _list[i] = _list[i + 1];
        }
        _list[_list.length - 1] = elementToMove;
        _list.pop();
        lockMapping[user] = _list;
    }
}
