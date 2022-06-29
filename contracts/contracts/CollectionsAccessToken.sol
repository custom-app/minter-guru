// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./InstaToken.sol";
import "./PrivateCollection.sol";

/// @dev CollectionsAccessToken contract has 3 main functions
/// 1. Factory of private collections.
/// 2. Access control for private collections. Owner of access token of collection is owner of collection and vice versa.
/// 3. Getter function for owned private collections or private collections with at least one owned item.
contract CollectionsAccessToken is ERC721Enumerable, AccessControl {
    using Clones for address;
    using Address for address;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @dev PrivateCollectionData - struct for collections list getter
    struct PrivateCollectionData {
        PrivateCollection contractAddress;    // collection contract address
        bytes data;                           // additional meta data of collection
    }

    /// @dev CollectionPurchased - emitted when collection is purchased
    event CollectionPurchased(address indexed owner, address indexed collection, uint256 indexed tokenId);

    mapping(uint256 => PrivateCollection) public tokenCollections;              // mapping from access token id to collection
    uint256 public tokensCount;                                                 // count of collection
    PrivateCollection public implementation;                                    // collection contract implementation for cloning
    InstaToken public token;                                                    // token contract address
    uint256 public collectionPrice;                                             // price of collection
    mapping(address => EnumerableSet.Bytes32Set) private ownedCollections;      // sets of owned collections or collections in which at least one token owned

    /// @dev check if call was made from private collection
    modifier onlyPrivateCollection(uint256 tokenId) {
        require(_msgSender() == address(tokenCollections[tokenId]), "");
        _;
    }

    /// @dev constructor
    /// @param name - access token name
    /// @param symbol - access token symbol
    /// @param _token - address of token contract
    /// @param _implementation - address of PrivateCollection contract for cloning
    /// @param _collectionPrice - price of private collection
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

    /// @dev function for private collection purchasing and cloning
    /// @param salt - value for cloning procedure to make address deterministic
    /// @param name - name of private collection token
    /// @param symbol - symbol of private collection token
    /// @param data - private collection metadata
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
        emit CollectionPurchased(_msgSender(), instance, tokenId);
    }

    /// @dev function for prediction of address of new collection
    /// @param salt - salt value for cloning
    function predictDeterministicAddress(bytes32 salt) external view returns (address) {
        return address(implementation).predictDeterministicAddress(salt, address(this));
    }

    /// @dev function to set new collection price
    /// @param newPrice - new collection price
    function setCollectionPrice(uint256 newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        collectionPrice = newPrice;
    }

    /// @dev function for changing private collection implementation
    /// @param _implementation - address of new instance of private collection
    function setImplementation(PrivateCollection _implementation) external onlyRole(DEFAULT_ADMIN_ROLE) {
        implementation = _implementation;
    }

    /// @dev function for updating private collection sets. Can be called only by PrivateCollection
    /// @param from - address of sender
    /// @param to - address of receiver
    /// @param tokenId - token id
    function updateCollectionIndex(
        address from,
        address to,
        uint256 tokenId
    ) external onlyPrivateCollection(tokenId) {
        if (from != address(0) && tokenCollections[tokenId].balanceOf(from) == 0 && ownerOf(tokenId) != from) {
            ownedCollections[from].remove(bytes32(tokenId));
        }

        if (to != address(0) && !ownedCollections[to].contains(bytes32(tokenId))) {
            ownedCollections[to].add(bytes32(tokenId));
        }
    }

    /// @dev function for retrieving collections list
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

    /// @dev inheritance conflict solving
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return AccessControl.supportsInterface(interfaceId) || ERC721Enumerable.supportsInterface(interfaceId);
    }

    /// @dev callback implementation for updating collections sets and transfer all tokens of transferred collection
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
