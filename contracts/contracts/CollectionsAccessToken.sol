// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./InstaToken.sol";
import "./PrivateCollection.sol";

contract CollectionsAccessToken is ERC721Enumerable, AccessControl {
    using Clones for address;
    using Address for address;

    mapping(uint256 => PrivateCollection) public tokenCollections;
    uint256 public tokensCount;
    PrivateCollection public implementation;
    InstaToken public token;
    uint256 public collectionPrice;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function purchasePrivateCollection(
        bytes32 salt,
        string memory name,
        string memory symbol
    ) external {
        token.burnWithOptionalReturn(_msgSender(), collectionPrice);
        uint256 tokenId = tokensCount;
        _mint(_msgSender(), tokenId);
        address instance = address(implementation).cloneDeterministic(salt);
        PrivateCollection(instance).initialize(name, symbol, this, tokenId, _msgSender());
        tokensCount++;
    }

    function predictDeterministicAddress(bytes32 salt) external view returns (address) {
        return address(implementation).predictDeterministicAddress(salt, _msgSender());
    }

    function setCollectionPrice(uint256 newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        collectionPrice = newPrice;
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return AccessControl.supportsInterface(interfaceId) || ERC721Enumerable.supportsInterface(interfaceId);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721) {
        super._afterTokenTransfer(from, to, tokenId);
        if (from != address(0) && to != address(to) && !to.isContract()) {
            tokenCollections[tokenId].transferOwnership(to);
        }
    }
}
