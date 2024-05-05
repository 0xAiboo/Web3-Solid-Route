// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts
// import "@openzeppelin/contracts/upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {console} from "forge-std/Test.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
import "./library/Address.sol";
import "./interface/TokensReceive.sol";

contract Base20Implementation is ERC20Upgradeable {
    error ERC20NotHave(address);
    error ERC20OnlyOneMint(address);
    event ERC20Mint(address sender, uint256 amount, uint256 balance);
    event finishMint(address sender, uint256 amount, uint256 balance);
    string private constant name_ = "Fatocry-Erc20";
    address private factoryAddress;
    uint256 public perMint;
    uint256 public price;
    uint256 public maxTotalSupply_;
    address[] public mintAddress;
    using Address for address;
    TokensReceive transferBack;
    constructor() {
        _disableInitializers();
    }
    function initialize(
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price,
        address _factoryAddress
    ) external initializer {
        __ERC20_init(name_, _symbol);
        perMint = _perMint;
        maxTotalSupply_ = _totalSupply;
        price = _price;
        factoryAddress = _factoryAddress;
    }
    function mimt(address mintUser) external payable {
        require(msg.sender == factoryAddress, "mint in fatory");
        console.log(maxTotalSupply_, mintAddress.length * perMint + perMint);
        if (maxTotalSupply_ < mintAddress.length * perMint + perMint)
            revert ERC20NotHave(mintUser);
        if (isUse(mintUser)) revert ERC20OnlyOneMint(mintUser);
        mintAddress.push(mintUser);
        if (maxTotalSupply_ == mintAddress.length * perMint) {
            for (uint i = 0; i < mintAddress.length; i++) {
                _mint(mintAddress[i], perMint);
                emit finishMint(
                    mintAddress[i],
                    perMint,
                    balanceOf(mintAddress[i])
                );
            }
            return;
        }
    }
    function isUse(address userAddress) internal view returns (bool) {
        for (uint i = 0; i < mintAddress.length; i++) {
            if (mintAddress[i] == userAddress) return true;
        }
        return false;
    }
    function priceOfOne() external view returns (uint256) {
        return perMint * price;
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
