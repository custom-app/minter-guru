// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract PublicCollection is ERC721EnumerableUpgradeable {
    mapping(uint256 => string) public tokenUris;
    mapping(uint256 => bytes) public tokenData;
    uint256 public tokensCount;
    uint256 public version;

    /// @dev Initialize
    function initialize(
        string memory name,
        string memory symbol,
        uint256 _version
    ) external initializer {
        __ERC721_init(name, symbol);
        version = _version;
        tokensCount = 0;
    }

    function mint(
        address to,
        uint256 id,
        string memory metaUri,
        bytes memory data
    ) external {
        require(id == tokensCount, "");
        tokensCount++;
        _safeMint(to, id);
        tokenUris[id] = metaUri;
        tokenData[id] = data;
    }

    function burn(uint256 id) external {
        require(ownerOf(id) == _msgSender(), "");
        _burn(id);
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUris[tokenId];
    }
}
