// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./CollectionsAccessToken.sol";

contract PrivateCollection is ERC721EnumerableUpgradeable {
    uint256 public accessTokenId;
    CollectionsAccessToken public accessToken;
    address public owner;
    uint256 public tokensCount;

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
        address _owner
    ) external initializer {
        __ERC721_init(name, symbol);
        accessTokenId = _accessTokenId;
        accessToken = _accessToken;
        owner = _owner;
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
}
