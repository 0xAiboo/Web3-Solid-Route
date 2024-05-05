// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IERC20Factory.sol";
import "./interface/IBase20Implementation.sol";
contract ERC20Factory is Ownable, IERC20Factory {
    uint256 public ratio = 10;
    address public erc20Implementation;
    constructor() Ownable(msg.sender) {}

    function setErc20Implementation(
        address _erc20Implementation
    ) public onlyOwner {
        erc20Implementation = _erc20Implementation;
        emit setERC20ImplementationEvent(_erc20Implementation);
    }

    function setRatio(uint256 _radio) public onlyOwner {
        ratio = _radio;
        emit setRatioEvent(_radio);
    }

    function deployInscription(
        string calldata symbol,
        uint totalSupply,
        uint perMint,
        uint price
    ) external {
        require(
            erc20Implementation == address(0),
            "Implementation address is null"
        );
        _clone(symbol, totalSupply, perMint, price);
    }
    function mintInscription(address tokenAddr) external payable {}

    function _clone(
        string calldata _symbol,
        uint _totalSupply,
        uint _perMint,
        uint _price
    ) internal {
        address newAddress = _create(erc20Implementation);
        IBase20Implementation(newAddress).initialize(
            _symbol,
            _totalSupply,
            _perMint,
            _price
        );
    }
    function _create(
        address _implementation
    ) internal returns (address result) {
        bytes20 targetBytes = bytes20(_implementation);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
        require(result != address(0), "ERC1167: create failed");
    }
}
