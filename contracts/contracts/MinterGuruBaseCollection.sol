// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @dev MinterCollection is the base contract with token list getter implementations
contract MinterGuruBaseCollection is ERC721EnumerableUpgradeable, OwnableUpgradeable {
    /// @dev TokenData - struct with basic token data
    struct TokenData {
        uint256 id;             // token id
        string metaUri;         // metadata uri
        bytes data;             // additional data
    }

    mapping(uint256 => string) public tokenUris;    // mapping of token metadata uri
    mapping(uint256 => bytes) public tokenData;     // mapping of token additional data
    uint256 public tokensCount;                     // minted tokens count
    string private contractMetaUri;                 // contract-level metadata

    /// @dev init function
    /// @param name - name of the token
    /// @param symbol - symbol of the token
    /// @param _contractMetaUri - contract-level metadata uri
    function __MinterCollection_init(
        string memory name,
        string memory symbol,
        string memory _contractMetaUri,
        address _owner
    ) internal onlyInitializing {
        __ERC721_init(name, symbol);
        tokensCount = 0;
        contractMetaUri = _contractMetaUri;
        _transferOwnership(_owner);
    }

    /// @dev function for retrieving all tokens. Implemented using basic pagination.
    /// @param page - page number (starting from zero)
    /// @param size - size of the page
    /// @return res - list of tokens
    /// @return total - number of tokens
    /// @notice This function is potentially unsafe, since it doesn't guarantee order (use fixed block number)
    function getAllTokens(uint256 page, uint256 size) external view returns (TokenData[] memory res, uint256 total) {
        require(size <= 1000, "MinterGuruBaseCollection: size must be 1000 or lower");
        total = totalSupply();
        require((total == 0 && page == 0) || page * size < total, "MinterGuruBaseCollection: out of bounds");
        uint256 resSize = size;
        if ((page + 1) * size > total) {
            resSize = total - page * size;
        }
        res = new TokenData[](resSize);
        for (uint256 i = page * size; i < page * size + resSize; i++) {
            uint256 tokenId = tokenByIndex(i);
            res[i - page * size] = TokenData(tokenId, tokenUris[tokenId], tokenData[tokenId]);
        }
        return (res, total);
    }

    /// @dev function for retrieving owned tokens. Implemented using basic pagination.
    /// @param page - page number (starting from zero)
    /// @param size - size of the page
    /// @return res - list of tokens
    /// @return total - number of tokens
    /// @notice This function is potentially unsafe, since it doesn't guarantee order (use fixed block number)
    function getSelfTokens(
        uint256 page,
        uint256 size
    ) external view returns (TokenData[] memory res, uint256 total) {
        require(size <= 1000, "MinterGuruBaseCollection: size must be 1000 or lower");
        total = balanceOf(_msgSender());
        require((total == 0 && page == 0) || page * size < total, "MinterGuruBaseCollection: out of bounds");
        uint256 resSize = size;
        if ((page + 1) * size > total) {
            resSize = total - page * size;
        }
        res = new TokenData[](resSize);
        for (uint256 i = page * size; i < page * size + resSize; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_msgSender(), i);
            res[i - page * size] = TokenData(tokenId, tokenUris[tokenId], tokenData[tokenId]);
        }
        return (res, total);
    }

    /// @dev Set contract-level metadata URI
    /// @param _contractMetaUri - new metadata URI
    function setContractMetaUri(
        string memory _contractMetaUri
    ) external onlyOwner {
        contractMetaUri = _contractMetaUri;
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    /// @return Metadata file URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUris[tokenId];
    }

    /// @dev Contract-level metadata for OpenSea
    /// @return Metadata file URI
    function contractURI() public view returns (string memory) {
        return contractMetaUri;
    }

    /// @dev mint function for using in inherited contracts
    /// @param to - token receiver
    /// @param id - token id
    /// @param metaUri - metadata uri
    /// @param data - additional token data
    function _mint(address to, uint256 id, string memory metaUri, bytes memory data) internal {
        require(id == tokensCount, "MinterGuruBaseCollection: wrong id");
        tokensCount++;
        _safeMint(to, id);
        tokenUris[id] = metaUri;
        tokenData[id] = data;
    }
}
