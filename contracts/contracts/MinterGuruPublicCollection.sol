// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./MinterGuruBaseCollection.sol";

/// @dev MinterGuruPublicCollection - collection where everyone can mint their photos
contract MinterGuruPublicCollection is MinterGuruBaseCollection {
    uint256 public version;  // contract version

    /// @dev Initialize function
    /// @param name - name of the token
    /// @param symbol - symbol of the token
    /// @param _version - contract version
    function initialize(
        string memory name,
        string memory symbol,
        uint256 _version
    ) external initializer {
        __MinterCollection_init(name, symbol);
        version = _version;
    }

    /// @dev mint function
    /// @param to - token receiver
    /// @param id - token id
    /// @param metaUri - metadata uri
    /// @param data - additional token data
    function mint(
        address to,
        uint256 id,
        string memory metaUri,
        bytes memory data
    ) external {
        _mint(to, id, metaUri, data);
    }

    /// @dev Mint function without id. Equivalent to mint(to, tokensCount(), metaUri, _data)
    /// @param to - token receiver
    /// @param metaUri - metadata uri
    /// @param _data - additional token data
    function mintWithoutId(
        address to,
        string memory metaUri,
        bytes memory _data
    ) external returns (uint256) {
        uint256 id = tokensCount;
        _mint(to, id, metaUri, _data);
        return id;
    }

    /// @dev burn function
    /// @param id - token id
    function burn(uint256 id) external {
        require(ownerOf(id) == _msgSender(), "PublicCollection: not owner of burning token");
        _burn(id);
    }
}
