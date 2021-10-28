// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DonateAndTakeNFT is ERC721, Ownable {
    
    //address public minter = address(this);
    address public minter;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Gift NTF", "DNTF") {}

    function mintNFT(address to)
        public returns (uint256)
    {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());

        return _tokenIdCounter.current();
    }
    
    function setMinter() external {
        minter = address(this);
    }
    
    
}
