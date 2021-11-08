
//Ropsten:
https://ropsten.etherscan.io/address/0x8f9de2150953b9b1f293b226038c51e7c66bde9a#code

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DonateAndTakeNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    constructor() ERC721("Gift NTF", "DNTF") {}

    function mint(address to)
        public returns (uint256)
    {
        uint256 newItemId = tokenCounter;
        tokenCounter = tokenCounter + 1;
        _mint(to, newItemId);
        return newItemId;
    }
    
}
