// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./PublicCollection.sol";

contract PublicCollectionsRouter is Ownable {
    using Clones for address;

    struct PublicCollectionData {
        PublicCollection contractAddress;
        uint256 version;
    }

    struct TokenData {
        uint256 id;
        string metaUri;
        bytes data;
    }

    event CollectionCreated(PublicCollection indexed instance, uint256 indexed version);

    event PublicMint(PublicCollection indexed collection, address indexed owner, uint256 indexed id);

    PublicCollection public implementation;
    mapping(uint256 => PublicCollection) public collections;
    PublicCollection[] public allCollections;
    uint256 public currentVersion = 0;

    constructor(PublicCollection _implementation) {
        implementation = _implementation;
    }

    function mint(
        uint256 version,
        uint256 id,
        string memory metaUri,
        bytes memory data
    ) external {
        require(allCollections.length > 0, "PublicCollectionsRouter: there are no collections to mint");
        PublicCollection collection = collections[version];
        require(address(collection) != address(0), "PublicCollectionsRouter: unknown version");
        require(collection.tokensCount() == id, "PublicCollectionsRouter: wrong id");
        collection.mint(_msgSender(), id, metaUri, data);
        emit PublicMint(collection, _msgSender(), id);
    }

    function createCollectionClone(
        bytes32 salt,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        PublicCollection instance = PublicCollection(address(implementation).cloneDeterministic(salt));
        instance.initialize(name, symbol, currentVersion);
        collections[currentVersion] = instance;
        allCollections.push() = instance;
        emit CollectionCreated(instance, currentVersion);
    }

    function changeImplementation(PublicCollection _implementation) external onlyOwner {
        implementation = _implementation;
        currentVersion++;
    }

    function predictDeterministicAddress(bytes32 salt) external view onlyOwner returns (address) {
        return address(implementation).predictDeterministicAddress(salt, address(this));
    }

    function idToMint(uint256 version) external view returns (uint256) {
        require(address(collections[version]) != address(0), "PublicCollectionsRouter: unknown version");
        return collections[version].tokensCount();
    }

    function totalTokens() public view returns (uint256) {
        return _totalTokens(_tokenCounts());
    }

    function getSelfPublicTokens(
        uint256 page,
        uint256 size
    ) external view returns (PublicCollectionData[] memory, TokenData[][] memory, uint256) {
        require(size <= 1000, "PublicCollectionsRouter: size must be 1000 or lower");
        uint256[] memory counts = _tokenCounts();
        uint256 total = _totalTokens(counts);
        require(page * size <= total, "PublicCollectionsRouter: out of bounds");

        bool[] memory mask = new bool[](counts.length);
        uint256 current = 0;
        uint256 ind = 0;
        uint256 resSize = size;
        if ((page + 1) * size > total) {
            resSize = total - page * size;
        }
        TokenData[][] memory res = new TokenData[][](counts.length);

        for (uint256 i = 0; i < counts.length; i++) {
            if (counts[i] > 0) {
                if (current >= page * size && current < (page + 1) * size) {
                    mask[i] = true;
                    uint256 collectionListSize = counts[i];
                    if (current + counts[i] > (page + 1) * size) {
                        collectionListSize = resSize - current;
                    }
                    res[i] = new TokenData[](collectionListSize);
                    for (uint256 j = 0; j < collectionListSize; j++) {
                        uint256 id = allCollections[i].tokenOfOwnerByIndex(_msgSender(), j);
                        res[i][j] = TokenData(id, allCollections[i].tokenURI(id), allCollections[i].tokenData(id));
                        ind++;
                    }
                } else if (page * size >= current && page * size < current + counts[i]) {
                    mask[i] = true;
                    uint256 collectionListSize = counts[i];
                    if (page * size > current) {
                        collectionListSize = current + counts[i] - page * size;
                    }
                    res[i] = new TokenData[](collectionListSize);
                    for (uint256 j = 0; j < collectionListSize; j++) {
                        uint256 id = allCollections[i].tokenOfOwnerByIndex(_msgSender(), counts[i] - collectionListSize + j);
                        res[i][j] = TokenData(id, allCollections[i].tokenURI(id), allCollections[i].tokenData(id));
                        ind++;
                    }
                }
            }
            current += counts[i];
        }
        return _filterSelfTokensResult(mask, res, total);
    }

    function _totalTokens(uint256[] memory counts) internal pure returns (uint256) {
        uint256 res = 0;
        for (uint256 i = 0; i < counts.length; i++) {
            res += counts[i];
        }
        return res;
    }

    function _tokenCounts() internal view returns (uint256[] memory) {
        uint256[] memory counts = new uint256[](allCollections.length);
        for (uint256 i = 0; i < counts.length; i++) {
            counts[i] = allCollections[i].balanceOf(_msgSender());
        }
        return counts;
    }

    function _filterSelfTokensResult(
        bool[] memory mask,
        TokenData[][] memory tokens,
        uint256 total
    ) internal view returns (PublicCollectionData[] memory, TokenData[][] memory, uint256) {
        uint256 collectionsCount = 0;
        for (uint256 i = 0; i < mask.length; i++) {
            if (mask[i]) {
                collectionsCount++;
            }
        }
        PublicCollectionData[] memory collectionsRes = new PublicCollectionData[](collectionsCount);
        TokenData[][] memory tokensRes = new TokenData[][](collectionsCount);
        uint256 index = 0;
        for (uint256 i = 0; i < mask.length; i++) {
            if (mask[i]) {
                collectionsRes[index] = PublicCollectionData(allCollections[i], allCollections[i].version());
                tokensRes[index] = tokens[i];
            }
        }
        return (collectionsRes, tokensRes, total);
    }
}
