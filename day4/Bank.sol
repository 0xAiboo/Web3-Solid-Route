// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

contract Bank {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    struct user {
        address addr;
        uint256 amount;
    }
    mapping(address => user) bankBook;
    user[3] rankList;

    address public owner;

    modifier onlyOwner() {
        require( owner == msg.sender, "not owner");
        _;
    }

    constructor(address  _owner) {
        owner = _owner;
    }
     function withdraw(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        (bool success, ) = _to.call{value: _value}(
            _data
        );
        require(success, "tx failed");
    }
    // function test() public view returns (bool) {
    //     return rankList[2].addr != address(0x0);
    // }
    // function getBankBool() public view returns (address[] memory) {
    //     address[] memory listAddress;
    //     user[] memory listUser;
    //     for (uint256 i = 0; i < bankBook.length; i++) {
    //         address.push(bankBook[i]);
    //         listUser.push(bankBook[i]);
    //     }
    //     return bankBook;
    // }

    function getRankList() public view returns (user[3] memory) {
        return rankList;
    }

    function refeshRank() private {
        bool isFullRank = rankList[2].addr != address(0x0);
        if (isFullRank) {
            bool isHave = false;
            for (uint256 i = 0; i < rankList.length; i++) {
                if (rankList[i].addr == msg.sender) {
                    rankList[i].amount += msg.value;
                    bubbleSort();
                    isHave = true;
                    break;
                }
            }
            if (!isHave) {
                if (bankBook[msg.sender].amount > rankList[2].amount) {
                    rankList[2] = bankBook[msg.sender];
                }
            }
        } else {
            bool isHave = false;
            for (uint256 i = 0; i < rankList.length; i++) {
                if (rankList[i].addr == msg.sender) {
                    rankList[i].amount += msg.value;
                    isHave = true;
                    break;
                }
            }
            if (!isHave) {
                bool isHaveRank = false;
                for (uint256 i = 0; i < rankList.length; i++) {
                    if (rankList[i].addr != address(0x0)) {
                        if (rankList[i].addr == msg.sender) {
                            rankList[i].amount += msg.value;
                            isHaveRank = true;
                            bubbleSort();
                            break;
                        }
                    } else {
                        user memory newUser;
                        newUser.addr = msg.sender;
                        newUser.amount = msg.value;
                        rankList[i] = newUser;
                        if(i==2){
                            bubbleSort();
                        }
                        // bubbleSort();
                        break;
                    }
                }
            }
        }
    }

    function bubbleSort() private {
        uint256 len = rankList.length;
        for (uint256 i = 0; i < len; i++) {
            for (uint256 j = 0; j < len - i; j++) {
                if (rankList[j].amount > rankList[j].amount) {
                    user memory temp = rankList[j];
                    rankList[j] = rankList[j];
                    rankList[j] = temp;
                }
            }
        }
    }

    function isNewUser() private view returns (bool) {
        if (bankBook[msg.sender].addr == address(0x0)) return true;
        return false;
    }

    receive() external payable {
        if (isNewUser()) {
            bankBook[msg.sender].addr = msg.sender;
            bankBook[msg.sender].amount = msg.value;
        } else {
            bankBook[msg.sender].amount += msg.value;
        }
        refeshRank();
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}
