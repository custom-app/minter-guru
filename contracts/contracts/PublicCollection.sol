// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract PublicCollection is ERC721EnumerableUpgradeable {
    uint256 public tokensCount;

    function initialize(
        string memory name,
        string memory symbol
    ) external initializer {
        __ERC721_init(name, symbol);
        tokensCount = 0;
    }

    function mint(address to, uint256 id) external {
        require(id == tokensCount, "");
        tokensCount++;
        _safeMint(to, id);
    }

    function burn(uint256 id) external {
        require(ownerOf(id) == _msgSender(), "");
        _burn(id);
    }
}
