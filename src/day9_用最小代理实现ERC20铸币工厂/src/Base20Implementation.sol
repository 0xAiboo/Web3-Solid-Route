// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts
import "@openzeppelin/contracts/upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
import "./library/Address.sol";
import "./interface/TokensReceive.sol";

contract Base20Implementation is ERC20Permit, Initializable {
    bool public isInit;
    string private constant name = "Fatocry-Erc20";
    uint256 private constant perMint;
    uint256 private constant price;
    using Address for address;

    TokensReceive transferBack;
    // constructor(
    //     string memory name_,
    //     string memory symbol_,
    //     uint256 totalSupply
    // ) ERC20(name_, symbol_) ERC20Permit(name_) {
    //     _mint(msg.sender, totalSupply);
    // }
    constructor() {}
    function initialize(
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price
    ) external initializer {
        new ERC20(name, _symbol);
        new ERC20Permit(name);
    }

    function _checkOnTokensReceived(address _to, bytes memory _data) private {}

    function transferWithCallback(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public {
        transfer(_to, _value);
        if (_to.isContract())
            TokensReceive(_to).tokensReceive(msg.sender, _to, _value, _data);
    }
}
