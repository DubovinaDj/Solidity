/*Task 3 [MEDIUM]:

*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@nomiclabs/builder/console.sol";

//import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/access/Ownable.sol";
//mport "@openzeppelin-contracts@4.0.0/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; 
import "./NFT.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Donation is Ownable  {
    
    NFT test;
    
    //address public immutable ADMIN;
    address public contractAddress;
    
    struct Campaign {               // grouped attributes
        string name;
        string description;
        uint duration;
        uint goal;
        uint raised;
        bool completed;
    }
    
    
    mapping(uint => Campaign) public campaigns;        //mapping from uint to Campaign attributes (id to Campaign)
    mapping(address => bool) public ownerDonated;       // mapping from address to bool (address - true or false)
    uint256 public Index = 0;
    
  
    function setNFTAddress(address _address) public onlyOwner {
        contractAddress = _address;
    }

    function getNFTAddress() public view returns (address) {
        return contractAddress;
    }

/*
    constructor() {
        ADMIN = payable(msg.sender);        
    }
    
    modifier onlyAdmin {
        require(msg.sender == ADMIN, "Only admin can call this function");
        _;
   }
*/
    
    // Create campaigns (only Admin can create campaigns)
    function createCampaign(
        string memory _name, string memory _description, 
        uint _duration, uint _goal
        ) public onlyOwner {
            
            uint raised = 0;
            bool completed = false;
            Index += 1;
            
            campaigns[Index] = Campaign(_name, _description, _duration + block.timestamp, _goal, raised, completed);
            
        }
        
    
    //Function for donation 
    function donate(uint _index) public payable  {
        
        require (block.timestamp < campaigns[_index].duration, "Campaign Failed!");
        require(campaigns[_index].raised < campaigns[_index].goal,"Goal achieved");


        campaigns[_index].raised += msg.value;
        
        if (campaigns[_index].raised + msg.value > campaigns[_index].goal) {     
            
            uint _amount =  campaigns[_index].raised - campaigns[_index].goal;
            campaigns[_index].raised -= _amount;
            campaigns[_index].completed = true;
            payable(msg.sender).call{value: _amount};
        } else if (campaigns[_index].raised == campaigns[_index].goal) campaigns[_index].completed = true;
        
        if (!ownerDonated[msg.sender]){                                                         //Donator will get NFT as gift first time only
            ownerDonated[msg.sender] = true;
           // minter1 = 0xd457540c3f08f7F759206B5eA9a4cBa321dE60DC;                                                                                   //Calling other contracts( NFT_ERC721.sol 
            NFT (contractAddress).mint(msg.sender);
        }
    }
}
