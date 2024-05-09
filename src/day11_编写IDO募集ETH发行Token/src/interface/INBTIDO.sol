// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface INBTIDO {
    struct IDOProject {
        address owner;
        uint256 price;
        uint256 min;
        uint256 max;
        uint256 end;
        uint256 tokenTotal;
        // uint256 amount;
        // mapping(address => uint256) ledger;
    }
    event IDOProjectAdd(address indexed token_ca, IDOProject _IDOProject);
    event IDOProjectPreSale(
        address indexed token_ca,
        address indexed perUser,
        uint256 amount
    );
    event IDOProjectRefund(
        address indexed token_ca,
        address indexed user,
        uint256 amount
    );
    event IDOProjectClaim(
        address indexed token_ca,
        address indexed user,
        uint256 amount
    );
    error ErrorProjectExisted(address token_ca);
    error ErrorProjectPrice(address token_ca);
    error ErrorProjectEnd(address token_ca);
    error ErrorProjectAmountInsufficient(address token_ca);

    error ErrorProjectNotEnd(address token_ca);
    error ErrorProjectSuccess(address token_ca);
    error ErrorProjectFailed(address token_ca);

    function addIDOProject(
        address token_ca,
        IDOProject memory _IDOProject
    ) external;
    function preSale(address token_ca) external payable;
    function refund(address token_ca) external;
}
