// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol"; 
import "./NFT.sol";


contract Donation is Ownable {
    
    DonateAndTakeNFT test;
    
    address public immutable ADMIN;
   
    address minter1;
    
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
    
    
    function setAddress(address _address) onlyAdmin public {
        test = DonateAndTakeNFT(_address);
    }
    
    constructor() {
        ADMIN = payable(msg.sender);        
    }
    
    modifier onlyAdmin {
        require(msg.sender == ADMIN, "Only admin can call this function");
        _;
    }
    
    
    // Create campaigns (only Admin can create campaigns)
    function createCampaign(
        uint _index, string memory _name, string memory _description, 
        uint _duration, uint _goal
        ) public onlyAdmin {
            
            uint raised = 0;
            bool completed = false;
            
            campaigns[_index] = Campaign(_name, _description, _duration + block.timestamp, _goal, raised, completed);
            
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
            minter1 = test.minter();
           // minter1 = 0xd457540c3f08f7F759206B5eA9a4cBa321dE60DC;                             //Calling other contracts( NFT_ERC721.sol 
            DonateAndTakeNFT (minter1).mintNFT(msg.sender);
        }

    }
    
}
