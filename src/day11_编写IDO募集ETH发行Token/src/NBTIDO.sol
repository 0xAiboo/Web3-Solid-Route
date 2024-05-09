// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./interface/INBTIDO.sol";
// # 编写IDO募集ETH发行Token
// ## 编写 IDO 合约，实现 Token 预售，需要实现如下功能：
// ### 1.开启预售: 支持对给定的任意ERC20开启预售，设定预售价格，募集ETH目标，超募上限，预售时长。
// ### 2.任意用户可支付ETH参与预售；
// ### 3.预售结束后，如果没有达到募集目标，则用户可领会退款；
// ### 4.预售成功，用户可领取 Token，且项目方可提现募集的ETH；
contract NBTIDO is INBTIDO {
    mapping(address => IDOProject) IDOProjectList;
    mapping(address => mapping(address => uint256)) IDOProjectLedger;
    mapping(address => uint256) IDOProjectAmount;
    ERC20Permit _token;
    constructor() {}
    function addIDOProject(
        address token_ca,
        IDOProject memory _IDOProject
    ) external {
        _addIDOProject(token_ca, _IDOProject);
    }
    function _addIDOProject(
        address token_ca,
        IDOProject memory _IDOProject
    ) internal {
        if (IDOProjectList[token_ca].end != 0)
            revert ErrorProjectExisted(token_ca);
        if (_IDOProject.tokenTotal * _IDOProject.price != _IDOProject.max)
            revert ErrorProjectPrice(token_ca);
        ERC20Permit(token_ca).transferFrom(
            msg.sender,
            address(this),
            _IDOProject.tokenTotal
        );
        _IDOProject.owner = msg.sender;
        IDOProjectList[token_ca] = _IDOProject;
        emit IDOProjectAdd(token_ca, _IDOProject);
    }
    function preSale(address token_ca) external payable {
        _preSale(token_ca);
    }
    function _preSale(address token_ca) internal {
        IDOProject memory _project = IDOProjectList[token_ca];
        if (block.timestamp > _project.end) revert ErrorProjectEnd(token_ca);
        if (IDOProjectAmount[token_ca] + msg.value > _project.max)
            revert ErrorProjectAmountInsufficient(token_ca);
        IDOProjectAmount[token_ca] += msg.value;
        IDOProjectLedger[token_ca][msg.sender] += msg.value;
        emit IDOProjectPreSale(token_ca, msg.sender, msg.value);
    }
    function refund(address token_ca) external {
        _refund(token_ca);
    }
    function _refund(address token_ca) internal {
        IDOProject memory _project = IDOProjectList[token_ca];
        if (_project.end > block.timestamp) revert ErrorProjectNotEnd(token_ca);
        if (IDOProjectAmount[token_ca] > _project.min)
            revert ErrorProjectSuccess(token_ca);
        if (_project.owner == msg.sender) {
            ERC20Permit(token_ca).transfer(msg.sender, _project.tokenTotal);
            emit IDOProjectRefund(token_ca, msg.sender, _project.tokenTotal);
        } else {
            uint256 refundAmount = IDOProjectLedger[token_ca][msg.sender];
            (bool tan, ) = payable(msg.sender).call{value: refundAmount}("");
            require(tan, "transfer failed");
            IDOProjectLedger[token_ca][msg.sender] = 0;
            IDOProjectAmount[token_ca] -= refundAmount;
            emit IDOProjectRefund(token_ca, msg.sender, refundAmount);
        }
    }
    function claim(address token_ca) external {
        _claim(token_ca);
    }
    function _claim(address token_ca) internal {
        IDOProject memory _project = IDOProjectList[token_ca];
        if (_project.end > block.timestamp) revert ErrorProjectNotEnd(token_ca);
        if (IDOProjectAmount[token_ca] < _project.min)
            revert ErrorProjectFailed(token_ca);

        if (_project.owner == msg.sender) {
            uint256 claimAmount = IDOProjectAmount[token_ca];
            (bool tan, ) = payable(msg.sender).call{value: claimAmount}("");
            require(tan, "transfer failed");

            IDOProjectAmount[token_ca] = 0;
            emit IDOProjectClaim(token_ca, msg.sender, claimAmount);
        } else {
            uint256 refundAmount = IDOProjectLedger[token_ca][msg.sender] /
                _project.price;
            ERC20Permit(token_ca).transfer(msg.sender, refundAmount);
            IDOProjectLedger[token_ca][msg.sender] = 0;
            emit IDOProjectClaim(token_ca, msg.sender, refundAmount);
        }
    }

    function _preSaleOfMe(address token_ca) external view returns (uint256) {
        return IDOProjectLedger[token_ca][msg.sender];
    }
    function _projectAmount(address token_ca) external view returns (uint256) {
        return IDOProjectAmount[token_ca];
    }
}
