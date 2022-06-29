// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./InstaToken.sol";
import "./PrivateCollection.sol";

contract CollectionsAccessToken is ERC721Enumerable, AccessControl {
    using Clones for address;
    using Address for address;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct PrivateCollectionData {
        PrivateCollection contractAddress;
        bytes data;
    }

    mapping(uint256 => PrivateCollection) public tokenCollections;
    uint256 public tokensCount;
    PrivateCollection public implementation;
    InstaToken public token;
    uint256 public collectionPrice;
    mapping(address => EnumerableSet.Bytes32Set) private ownedCollections;

    modifier onlyPrivateCollection(uint256 tokenId) {
        require(_msgSender() == address(tokenCollections[tokenId]), "");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        InstaToken _token,
        PrivateCollection _implementation,
        uint256 _collectionPrice
    ) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = _token;
        implementation = _implementation;
        collectionPrice = _collectionPrice;
    }

    function purchasePrivateCollection(
        bytes32 salt,
        string memory name,
        string memory symbol,
        bytes memory data
    ) external {
        token.burnWithOptionalReturn(_msgSender(), collectionPrice);
        uint256 tokenId = tokensCount;
        _mint(_msgSender(), tokenId);
        address instance = address(implementation).cloneDeterministic(salt);
        PrivateCollection(instance).initialize(name, symbol, this, tokenId, _msgSender(), data);
        tokensCount++;
        ownedCollections[_msgSender()].add(bytes32(tokenId));
    }

    function predictDeterministicAddress(bytes32 salt) external view returns (address) {
        return address(implementation).predictDeterministicAddress(salt, address(this));
    }

    function setCollectionPrice(uint256 newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        collectionPrice = newPrice;
    }

    function setImplementation(PrivateCollection _implementation) external onlyRole(DEFAULT_ADMIN_ROLE) {
        implementation = _implementation;
    }

    function updateCollectionIndex(
        address from,
        address to,
        uint256 tokenId
    ) external onlyPrivateCollection(tokenId) {
        if (tokenCollections[tokenId].balanceOf(from) == 0 && ownerOf(tokenId) != from) {
            ownedCollections[from].remove(bytes32(tokenId));
        }

        if (!ownedCollections[to].contains(bytes32(tokenId))) {
            ownedCollections[to].add(bytes32(tokenId));
        }
    }

    function getSelfCollections(
        uint256 page,
        uint256 size
    ) external view returns (PrivateCollectionData[] memory, uint256) {
        require(size <= 1000, "CollectionsAccessToken: size must be 1000 or lower");
        uint256 total = ownedCollections[_msgSender()].length();
        require((total == 0 && page == 0) || page * size < total, "CollectionsAccessToken: out of bounds");
        uint256 resSize = size;
        if (page * (size + 1) < total) {
            resSize = total - page * size;
        }
        PrivateCollectionData[] memory res = new PrivateCollectionData[](resSize);
        for (uint256 i = page * size; i < page * size + resSize; i++) {
            uint256 tokenId = uint256(ownedCollections[_msgSender()].at(i));
            res[i - page * size] = PrivateCollectionData(tokenCollections[tokenId], tokenCollections[tokenId].data());
        }
        return (res, total);
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
            ownedCollections[from].remove(bytes32(tokenId));
            if (!ownedCollections[to].contains(bytes32(tokenId))) {
                ownedCollections[to].add(bytes32(tokenId));
            }
        }
    }
}
