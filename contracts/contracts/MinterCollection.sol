// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

/// @dev MinterCollection is the base contract with token list getter implementations
contract MinterCollection is ERC721EnumerableUpgradeable {
    /// @dev TokenData - struct with basic token data
    struct TokenData {
        uint256 id;             // token id
        string metaUri;         // metadata uri
        bytes data;             // additional data
    }

    mapping(uint256 => string) public tokenUris;    // mapping of token metadata uri
    mapping(uint256 => bytes) public tokenData;     // mapping of token additional data
    uint256 public tokensCount;                     // minted tokens count

    /// @dev init function
    /// @param name - name of the token
    /// @param symbol - symbol of the token
    function __MinterCollection_init(
        string memory name,
        string memory symbol
    ) internal onlyInitializing {
        __ERC721_init(name, symbol);
        tokensCount = 0;
    }

    /// @dev function for retrieving all tokens. It uses basic pagination method.
    /// @param page - page number (starting from zero)
    /// @param size - size of the page
    /// @return res - list of tokens
    /// @return total - number of tokens
    /// @notice This function is potentially unsafe, since it doesn't guarantee order
    function getAllTokens(uint256 page, uint256 size) external view returns (TokenData[] memory res, uint256 total) {
        require(size <= 1000, "MinterCollection: size must be 1000 or lower");
        total = totalSupply();
        require((total == 0 && page == 0) || page * size < total, "MinterCollection: out of bounds");
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

    /// @dev function for retrieving owned tokens. It uses basic pagination method.
    /// @param page - page number (starting from zero)
    /// @param size - size of the page
    /// @return res - list of tokens
    /// @return total - number of tokens
    /// @notice This function is potentially unsafe, since it doesn't guarantee order
    function getSelfTokens(
        uint256 page,
        uint256 size
    ) external view returns (TokenData[] memory res, uint256 total) {
        require(size <= 1000, "MinterCollection: size must be 1000 or lower");
        total = balanceOf(_msgSender());
        require((total == 0 && page == 0) || page * size < total, "MinterCollection: out of bounds");
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

    /// @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUris[tokenId];
    }

    /// @dev mint function for using in inherited contracts
    /// @param to - token receiver
    /// @param id - token id
    /// @param metaUri - metadata uri
    /// @param data - additional token data
    function _mint(address to, uint256 id, string memory metaUri, bytes memory data) internal {
        require(id == tokensCount, "MinterCollection: wrong id");
        tokensCount++;
        _safeMint(to, id);
        tokenUris[id] = metaUri;
        tokenData[id] = data;
    }
}
