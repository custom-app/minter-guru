// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./PublicCollection.sol";

contract PublicCollectionsRouter is Ownable {
    using Clones for address;

    event CollectionCreated(PublicCollection indexed instance);

    event CollectionDeprecated(PublicCollection indexed instance);

    event PublicMint(PublicCollection indexed collection, address indexed owner, uint256 indexed id);

    PublicCollection public implementation;
    PublicCollection[] public collections;
    PublicCollection[] public allCollections;
    mapping(PublicCollection => uint256) public indices;

    constructor(PublicCollection _implementation) {
        implementation = _implementation;
    }

    function mint(
        PublicCollection collection,
        uint256 id
    ) external {
        require(collections.length > 1, "PublicCollectionsRouter: there are no collections to mint");
        require(indices[collection] > 0, "PublicCollectionsRouter: collection doesn't exist");
        require(collection.tokensCount() == id, "PublicCollectionsRouter: wrong id");
        collection.mint(_msgSender(), id);
        emit PublicMint(collection, _msgSender(), id);
    }

    function mintWithoutParams() external {
        PublicCollection collection;
        uint256 id;
        (collection, id) = this.dataToMint();
        collection.mint(_msgSender(), id);
        emit PublicMint(collection, _msgSender(), id);
    }

    function createCollectionClone(
        bytes32 salt,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        PublicCollection instance = PublicCollection(address(implementation).cloneDeterministic(salt));
        instance.initialize(name, symbol);
        collections.push() = instance;
        allCollections.push() = instance;
        indices[instance] = collections.length;
        emit CollectionCreated(instance);
    }

    function deprecateCollectionClone(
        PublicCollection collection
    ) external onlyOwner {
        uint256 ind = indices[collection];
        require(ind > 0, "PublicCollectionRouter: collection doesn't exist");
        collections[ind - 1] = collections[collections.length - 1];
        collections.pop();
        emit CollectionDeprecated(collection);
    }

    function dataToMint() external view returns (PublicCollection, uint256) {
        require(collections.length > 1, "PublicCollectionsRouter: there are no collections to mint");
        PublicCollection collection = collections[block.timestamp % collections.length];
        return (collection, collection.tokensCount());
    }

    function predictDeterministicAddress(bytes32 salt) external view onlyOwner returns (address) {
        return address(implementation).predictDeterministicAddress(salt, _msgSender());
    }
}
