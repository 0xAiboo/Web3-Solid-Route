// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

abstract contract Bank {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    mapping(address => uint256) bankBook;
    address[3] rankList;

    function getRankList() public view returns (address[3] memory) {
        return rankList;
    }

    function refeshRank() private {
        bool isFullRank = rankList[2] != address(0x0);
        if (isFullRank) {
            uint256 newAmount = bankBook[msg.sender];
            bool isInRank = false;
            for (uint8 i = 0; i < rankList.length; i++) {
                if (rankList[i] == msg.sender) {
                    isInRank = true;
                    break;
                }
            }
            if (!isInRank) {
                if (newAmount > bankBook[rankList[2]]) {
                    rankList[2] = msg.sender;
                }
            }
        } else {
            for (uint8 i = 0; i < rankList.length; i++) {
                if (rankList[i] == msg.sender) break;
                if (rankList[i] == address(0x0)) {
                    rankList[i] = msg.sender;
                    break;
                }
            }
        }
        bubbleSort();
    }

    function bubbleSort() private {
        uint256 n = rankList.length;

        for (uint8 i = 0; i < n - 1; i++) {
            for (uint8 j = 0; j < n - i - 1; j++) {
                if (bankBook[rankList[j]] < bankBook[rankList[j + 1]]) {
                    (rankList[j], rankList[j + 1]) = (
                        rankList[j + 1],
                        rankList[j]
                    );
                }
            }
        }
    }

   

    function depositMoney() internal {
        bankBook[msg.sender] += msg.value;
        refeshRank();
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    receive() external payable virtual {
        depositMoney();
    }
}
