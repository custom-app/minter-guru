// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./CollectionsAccessToken.sol";

contract PrivateCollection is ERC721EnumerableUpgradeable {
    struct TokenData {
        uint256 id;
        string metaUri;
        bytes data;
    }

    uint256 public accessTokenId;
    CollectionsAccessToken public accessToken;
    address public owner;
    uint256 public tokensCount;
    bytes public data;

    mapping(uint256 => string) public tokenUris;
    mapping(uint256 => bytes) public tokenData;

    modifier onlyAccessToken() {
        require(_msgSender() == address(accessToken), "");
        _;
    }

    modifier onlyOwner() {
        require(_msgSender() == owner, "");
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        CollectionsAccessToken _accessToken,
        uint256 _accessTokenId,
        address _owner,
        bytes memory _data
    ) external initializer {
        __ERC721_init(name, symbol);
        accessTokenId = _accessTokenId;
        accessToken = _accessToken;
        owner = _owner;
        data = _data;
    }

    function mint(
        address to,
        uint256 id
    ) external onlyOwner {
        require(id == tokensCount, "");
        _safeMint(to, id);
        tokensCount++;
    }

    function burn(uint256 id) external {
        require(ownerOf(id) == _msgSender(), "");
        _burn(id);
    }

    function transferOwnership(address to) external onlyAccessToken {
        uint256 ownerTokensCount = balanceOf(owner);
        for (uint256 i = 0; i < ownerTokensCount; i++) {
            uint256 id = tokenOfOwnerByIndex(owner, i);
            _transfer(owner, to, id);
        }
        owner = to;
    }

    function getSelfTokens(
        uint256 page,
        uint256 size
    ) external view returns (TokenData[] memory, uint256) {
        require(size <= 1000, "PrivateCollection: size must be 1000 or lower");
        uint256 total = balanceOf(_msgSender());
        require((total == 0 && page == 0) || page * size < total, "PrivateCollection: out of bounds");
        uint256 resSize = size;
        if (page * (size + 1) < total) {
            resSize = total - page * size;
        }
        TokenData[] memory res = new TokenData[](resSize);
        for (uint256 i = page * size; i < page * size + resSize; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_msgSender(), i);
            res[i - page * size] = TokenData(tokenId, tokenUris[tokenId], tokenData[tokenId]);
        }
        return (res, total);
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUris[tokenId];
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from, to, tokenId);
        accessToken.updateCollectionIndex(from, to, tokenId);
    }
}
