// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721 {
    using Strings for uint256;
    using Address for address;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Token baseURI
    string private _baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Initializes the contract by setting a `name`, a `symbol` and a `baseURI` to the token collection.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) {
        /**code*/
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        /**code*/
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        /**code*/
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(
            /**code*/
            _owners[tokenId] != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );
        // should return baseURI
        /**code*/
        // string memory ab = new string(_baseURI);
        string memory baseURI = _baseURI;
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(),".json") : "";
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` must not exist.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, uint256 tokenId) public {
        require(
            /**code*/
            to != address(0),
            "ERC721: mint to the zero address"
        );
        require(
            /**code*/
            _owners[tokenId] == address(0),
            "ERC721: token already minted"
        );

        /**code*/
        _owners[tokenId] = to;
        _balances[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view returns (uint256) {
        /**code*/
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        /**code*/
        return _owners[tokenId];
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(
            /**code*/
            owner != to,
            "ERC721: approval to current owner"
        );

        require(
            /**code*/
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            /**code*/
            _owners[tokenId] != address(0),
            "ERC721: approved query for nonexistent token"
        );

        /**code*/
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        address sender = msg.sender;
        require(
            /**code*/
            sender != operator,
            "ERC721: approve to caller"
        );

        /**code*/
        _operatorApprovals[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        /**code*/
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        _transfer(from, to, tokenId);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        /**code*/
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );

        /**code*/
        address owner = ownerOf(tokenId);
        return
            _tokenApprovals[tokenId] == spender ||
            _owners[tokenId] == spender ||
            _operatorApprovals[owner][spender];
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(
            /**code*/
            _owners[tokenId] == from,
            "ERC721: transfer from incorrect owner"
        );

        require(
            /**code*/
            to != address(0),
            "ERC721: transfer to the zero address"
        );

        /**code*/
        _owners[tokenId] = to;
        _balances[from] -= 1;
        _balances[to] += 1;
        _tokenApprovals[tokenId] = address(0);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        /**code*/
        require(_owners[tokenId] != to, "You are the owner of the token");
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function isContract(address addr) private returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(addr)
        }

        return size > 0;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (isContract(to)) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

contract BaseERC721Receiver is IERC721Receiver {
    constructor() {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
