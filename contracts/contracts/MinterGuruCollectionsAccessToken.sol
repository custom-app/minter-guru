// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./MinterGuruToken.sol";
import "./MinterGuruPrivateCollection.sol";

/// @dev MinterGuruCollectionsAccessToken contract has 3 main functions
/// 1. Factory of private collections.
/// 2. Access control for private collections. Owner of access token of collection is owner of collection and vice versa.
/// 3. Getter function for owned private collections or private collections with at least one owned item.
contract MinterGuruCollectionsAccessToken is ERC721Enumerable, AccessControl {
    using Clones for address;
    using Address for address;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @dev PrivateCollectionData - struct for collections list getter
    struct PrivateCollectionData {
        MinterGuruPrivateCollection contractAddress;    // collection contract address
        bytes data;                                   // additional meta data of collection
    }

    /// @dev CollectionPurchased - emitted when collection is purchased
    event CollectionPurchased(address indexed owner, address indexed collection, uint256 indexed tokenId);

    mapping(uint256 => MinterGuruPrivateCollection) public tokenCollections;      // mapping from access token id to collection
    uint256 public tokensCount;                                                 // count of collection
    MinterGuruPrivateCollection public implementation;                            // collection contract implementation for cloning
    MinterGuruToken public token;                                                 // token contract address
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
        MinterGuruToken _token,
        MinterGuruPrivateCollection _implementation,
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
        tokenCollections[tokenId] = MinterGuruPrivateCollection(instance);
        MinterGuruPrivateCollection(instance).initialize(name, symbol, this, tokenId, _msgSender(), data);
        tokensCount++;
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
    function setImplementation(MinterGuruPrivateCollection _implementation) external onlyRole(DEFAULT_ADMIN_ROLE) {
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
    /// @param page - page number (starting from zero)
    /// @param size - size of the page
    /// @return collection list and owned tokens count for each collection
    function getSelfCollections(
        uint256 page,
        uint256 size
    ) external view returns (PrivateCollectionData[] memory, uint256[] memory) {
        require(size <= 1000, "CollectionsAccessToken: size must be 1000 or lower");
        uint256 total = ownedCollections[_msgSender()].length();
        require((total == 0 && page == 0) || page * size < total, "CollectionsAccessToken: out of bounds");
        uint256 resSize = size;
        if ((page + 1) * size > total) {
            resSize = total - page * size;
        }
        PrivateCollectionData[] memory res = new PrivateCollectionData[](resSize);
        uint256[] memory counts = new uint256[](resSize);
        for (uint256 i = page * size; i < page * size + resSize; i++) {
            uint256 tokenId = uint256(ownedCollections[_msgSender()].at(i));
            res[i - page * size] = PrivateCollectionData(tokenCollections[tokenId], tokenCollections[tokenId].data());
            counts[i - page*size] = tokenCollections[tokenId].balanceOf(_msgSender());
        }
        return (res, counts);
    }

    /// @dev function for retrieving token lists
    /// @param ids - ids of tokens
    /// @param pages - page numbers (starting from zero)
    /// @param sizes - sizes of the pages
    /// @return owned token lists
    function getSelfTokens(
        uint256[] calldata ids,
        uint256[] calldata pages,
        uint256[] calldata sizes
    ) external view returns (MinterGuruBaseCollection.TokenData[][] memory) {
        require(ids.length <= 1000, "CollectionsAccessToken: collections quantity must be 1000 or lower");
        require(ids.length == pages.length && pages.length == sizes.length, "CollectionsAccessToken: lengths unmatch");
        MinterGuruBaseCollection.TokenData[][] memory res = new MinterGuruBaseCollection.TokenData[][](ids.length);
        uint256 realSize = 0;
        uint256[] memory resSizes = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            require(address(tokenCollections[ids[i]]) != address(0), "CollectionsAccessToken: collection doesn't exist");
            uint256 total = tokenCollections[ids[i]].balanceOf(_msgSender());
            require((total == 0 && pages[i] == 0) || pages[i] * sizes[i] < total, "CollectionsAccessToken: out of bounds");
            resSizes[i] = sizes[i];
            if ((pages[i] + 1) * sizes[i] > total) {
                resSizes[i] = total - pages[i] * sizes[i];
            }
            realSize += resSizes[i];
            res[i] = new MinterGuruBaseCollection.TokenData[](resSizes[i]);
        }
        require(realSize <= 1000, "CollectionsAccessToken: tokens quantity must be 1000 or lower");
        for (uint256 i = 0; i < ids.length; i++) {
            MinterGuruPrivateCollection collection = tokenCollections[ids[i]];
            for (uint256 j = pages[i] * sizes[i]; j < pages[i] * sizes[i] + resSizes[i]; j++) {
                uint256 tokenId = collection.tokenOfOwnerByIndex(_msgSender(), j);
                res[i][j - pages[i] * sizes[i]] = MinterGuruBaseCollection.TokenData(tokenId,
                    collection.tokenUris(tokenId), collection.tokenData(tokenId));
            }
        }
        return res;
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
        if (from != address(0) && to != address(0) && !to.isContract()) {
            tokenCollections[tokenId].transferOwnership(to);
        }
        if (from != address(0)) {
            ownedCollections[from].remove(bytes32(tokenId));
        }
        if (to != address(0) && !ownedCollections[to].contains(bytes32(tokenId))) {
            ownedCollections[to].add(bytes32(tokenId));
        }
    }
}
