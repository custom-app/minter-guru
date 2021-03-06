// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./MinterGuruCollectionsAccessToken.sol";
import "./MinterGuruBaseCollection.sol";

/// @dev MinterGuruPrivateCollection - collection where only the owner can mint photos
contract MinterGuruPrivateCollection is MinterGuruBaseCollection {
    uint256 public accessTokenId;                              // access token id
    MinterGuruCollectionsAccessToken public accessToken;         // Access token contract address
    address public owner;                                      // current owner. changed on access token transfers
    bytes public data;                                         // collection additional data

    /// @dev modifier for checking if call is from the access token contract
    modifier onlyAccessToken() {
        require(_msgSender() == address(accessToken), "");
        _;
    }

    /// @dev modifier for checking if call is from the owner
    modifier onlyOwner() {
        require(_msgSender() == owner, "");
        _;
    }

    /// @dev initialize function
    /// @param name - name of the token
    /// @param symbol - symbol of the token
    /// @param _accessToken - access token contract address
    /// @param _accessTokenId - access token id
    /// @param _owner - collection creator
    /// @param _data - additional collection data
    function initialize(
        string memory name,
        string memory symbol,
        MinterGuruCollectionsAccessToken _accessToken,
        uint256 _accessTokenId,
        address _owner,
        bytes memory _data
    ) external initializer {
        __MinterCollection_init(name, symbol);
        accessTokenId = _accessTokenId;
        accessToken = _accessToken;
        owner = _owner;
        data = _data;
    }

    /// @dev Mint function. Can called only by the owner
    /// @param to - token receiver
    /// @param id - token id
    /// @param metaUri - metadata uri
    /// @param _data - additional token data
    function mint(
        address to,
        uint256 id,
        string memory metaUri,
        bytes memory _data
    ) external onlyOwner {
        _mint(to, id, metaUri, _data);
    }

    /// @dev Mint function without id. Can called only by the owner. Equivalent to mint(to, tokensCount(), metaUri, _data)
    /// @param to - token receiver
    /// @param metaUri - metadata uri
    /// @param _data - additional token data
    function mintWithoutId(
        address to,
        string memory metaUri,
        bytes memory _data
    ) external onlyOwner returns (uint256) {
        uint256 id = tokensCount;
        _mint(to, id, metaUri, _data);
        return id;
    }

    /// @dev burn function
    /// @param id - token id
    function burn(uint256 id) external {
        require(ownerOf(id) == _msgSender(), "");
        _burn(id);
    }

    /// @dev function for transferring all owned tokens in collection
    function transferOwnership(address to) external onlyAccessToken {
        uint256 ownerTokensCount = balanceOf(owner);
        for (uint256 i = 0; i < ownerTokensCount; i++) {
            uint256 id = tokenOfOwnerByIndex(owner, i);
            _transfer(owner, to, id);
        }
        owner = to;
    }

    /// @dev callback implementation for updating collections sets in access token contract
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from, to, tokenId);
        accessToken.updateCollectionIndex(from, to, accessTokenId);
    }
}
