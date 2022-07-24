// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./MinterGuruPublicCollection.sol";

/// @dev MinterGuruPublicCollectionsRouter is contract for minting photos to public collections
contract MinterGuruPublicCollectionsRouter is Ownable {
    using Clones for address;

    /// @dev PublicCollectionData - public collection data
    struct PublicCollectionData {
        MinterGuruPublicCollection contractAddress;        // address of contract
        uint256 version;                                   // version
    }

    /// @dev emitted when new public collection is cloned
    event CollectionCreated(MinterGuruPublicCollection indexed instance, uint256 indexed version);

    /// @dev emitted when new photo is minted
    event PublicMint(MinterGuruPublicCollection indexed collection, address indexed owner, uint256 indexed id);

    MinterGuruPublicCollection public implementation;                        // public collection contract implementation for cloning
    mapping(uint256 => MinterGuruPublicCollection) public collections;       // current public collections for each version
    MinterGuruPublicCollection[] public allCollections;                      // list of all cloned collections
    uint256 public currentVersion = 0;                                       // current version

    /// @dev constructor
    /// @param _implementation - address of PublicCollection contract for cloning
    constructor(MinterGuruPublicCollection _implementation) {
        implementation = _implementation;
    }

    /// @dev mint function
    /// @param version - collection version
    /// @param id - token id
    /// @param metaUri - token metadata uri
    /// @param data - additional data
    function mint(
        uint256 version,
        uint256 id,
        string memory metaUri,
        bytes memory data
    ) external {
        require(allCollections.length > 0, "MinterGuruPublicCollectionsRouter: there are no collections to mint");
        MinterGuruPublicCollection collection = collections[version];
        require(address(collection) != address(0), "MinterGuruPublicCollectionsRouter: unknown version");
        collection.mint(_msgSender(), id, metaUri, data);
        emit PublicMint(collection, _msgSender(), id);
    }

    /// @dev mint function. Equivalent to mint(version, collections[version].tokensCount(), metaUri, data)
    /// @param version - collection version
    /// @param metaUri - token metadata uri
    /// @param data - additional data
    function mintWithoutId(
        uint256 version,
        string memory metaUri,
        bytes memory data
    ) external {
        require(allCollections.length > 0, "MinterGuruPublicCollectionsRouter: there are no collections to mint");
        MinterGuruPublicCollection collection = collections[version];
        require(address(collection) != address(0), "MinterGuruPublicCollectionsRouter: unknown version");
        uint256 id = collection.mintWithoutId(_msgSender(), metaUri, data);
        emit PublicMint(collection, _msgSender(), id);
    }

    /// @dev function for creating collection clone
    /// @param salt - salt value for cloning
    /// @param name - name of the token
    /// @param symbol - symbol of the token
    function createCollectionClone(
        bytes32 salt,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        MinterGuruPublicCollection instance = MinterGuruPublicCollection(address(implementation).cloneDeterministic(salt));
        instance.initialize(name, symbol, currentVersion);
        collections[currentVersion] = instance;
        allCollections.push() = instance;
        emit CollectionCreated(instance, currentVersion);
    }

    /// @dev function for changing private collection implementation
    /// @param _implementation - address of new instance of private collection
    function setImplementation(MinterGuruPublicCollection _implementation) external onlyOwner {
        implementation = _implementation;
        currentVersion++;
    }

    /// @dev function for prediction of address of new collection
    /// @param salt - salt value for cloning
    /// @return predicted address
    function predictDeterministicAddress(bytes32 salt) external view onlyOwner returns (address) {
        return address(implementation).predictDeterministicAddress(salt, address(this));
    }

    /// @dev function for getting id for minting
    /// @return id to mint
    function idToMint(uint256 version) external view returns (uint256) {
        require(address(collections[version]) != address(0), "MinterGuruPublicCollectionsRouter: unknown version");
        return collections[version].tokensCount();
    }

    /// @dev function for calculating total amount of owned tokens in all collections
    /// @return res - amount of owned tokens in all collections
    function totalTokens() public view returns (uint256 res) {
        return _totalTokens(_tokenCounts());
    }

    /// @dev function for retrieving token lists grouped by collection. It uses basic pagination method.
    /// @param page - page number (starting from zero)
    /// @param size - size of the page
    /// @return collectionsRes - list of collections
    /// @return tokensRes - list of lists of tokens
    /// @return total - owned tokens count
    function getSelfPublicTokens(
        uint256 page,
        uint256 size
    ) external view returns (
        PublicCollectionData[] memory collectionsRes,
        MinterGuruBaseCollection.TokenData[][] memory tokensRes,
        uint256 total
    ) {
        require(size <= 1000, "MinterGuruPublicCollectionsRouter: size must be 1000 or lower");
        uint256[] memory counts = _tokenCounts();
        uint256 _total = _totalTokens(counts);
        require((total == 0 && page == 0) || page * size < _total, "MinterGuruPublicCollectionsRouter: out of bounds");

        bool[] memory mask = new bool[](counts.length);
        uint256 current = 0;
        uint256 ind = 0;
        uint256 resSize = size;
        if ((page + 1) * size > _total) {
            resSize = _total - page * size;
        }
        MinterGuruBaseCollection.TokenData[][] memory res = new MinterGuruBaseCollection.TokenData[][](counts.length);

        for (uint256 i = 0; i < counts.length; i++) {
            if (counts[i] > 0) {
                if (current >= page * size && current < (page + 1) * size) {
                    mask[i] = true;
                    uint256 collectionListSize = counts[i];
                    if (current + counts[i] > (page + 1) * size) {
                        collectionListSize = resSize - current;
                    }
                    res[i] = new MinterGuruBaseCollection.TokenData[](collectionListSize);
                    for (uint256 j = 0; j < collectionListSize; j++) {
                        uint256 id = allCollections[i].tokenOfOwnerByIndex(_msgSender(), j);
                        res[i][j] = MinterGuruBaseCollection.TokenData(id, allCollections[i].tokenURI(id), allCollections[i].tokenData(id));
                        ind++;
                    }
                } else if (page * size >= current && page * size < current + counts[i]) {
                    mask[i] = true;
                    uint256 collectionListSize = counts[i];
                    if (page * size > current) {
                        collectionListSize = current + counts[i] - page * size;
                    }
                    res[i] = new MinterGuruBaseCollection.TokenData[](collectionListSize);
                    for (uint256 j = 0; j < collectionListSize; j++) {
                        uint256 id = allCollections[i].tokenOfOwnerByIndex(_msgSender(), counts[i] - collectionListSize + j);
                        res[i][j] = MinterGuruBaseCollection.TokenData(id, allCollections[i].tokenURI(id), allCollections[i].tokenData(id));
                        ind++;
                    }
                }
            }
            current += counts[i];
        }
        return _buildSelfTokensResult(mask, res, _total);
    }

    /// @dev function for calculating total amount of owned tokens in all collections
    /// @return res - amount of owned tokens in all collections
    function _totalTokens(uint256[] memory counts) internal pure returns (uint256 res) {
        res = 0;
        for (uint256 i = 0; i < counts.length; i++) {
            res += counts[i];
        }
        return res;
    }

    /// @dev function for calculating total amount of owned tokens in each collection
    /// @return counts - counts of owned tokens in all collection
    function _tokenCounts() internal view returns (uint256[] memory counts) {
        counts = new uint256[](allCollections.length);
        for (uint256 i = 0; i < counts.length; i++) {
            counts[i] = allCollections[i].balanceOf(_msgSender());
        }
        return counts;
    }

    /// @dev function for building non empty groups (grouping is made by collection) of tokens
    /// @param mask - list of bools indicating if group is empty
    /// @param tokens - lists of grouped tokens
    /// @param _total - total tokens
    /// @return collectionsRes - list of collections
    /// @return tokensRes - list of lists of tokens
    /// @return total - owned tokens count
    function _buildSelfTokensResult(
        bool[] memory mask,
        MinterGuruBaseCollection.TokenData[][] memory tokens,
        uint256 _total
    ) internal view returns (
        PublicCollectionData[] memory collectionsRes,
        MinterGuruBaseCollection.TokenData[][] memory tokensRes,
        uint256 total
    ) {
        uint256 collectionsCount = 0;
        for (uint256 i = 0; i < mask.length; i++) {
            if (mask[i]) {
                collectionsCount++;
            }
        }
        collectionsRes = new PublicCollectionData[](collectionsCount);
        tokensRes = new MinterGuruBaseCollection.TokenData[][](collectionsCount);
        uint256 index = 0;
        for (uint256 i = 0; i < mask.length; i++) {
            if (mask[i]) {
                collectionsRes[index] = PublicCollectionData(allCollections[i], allCollections[i].version());
                tokensRes[index] = tokens[i];
                index++;
            }
        }
        return (collectionsRes, tokensRes, _total);
    }
}
