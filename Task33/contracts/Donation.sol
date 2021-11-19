// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "./NFT.sol";

contract Donation is Ownable {
    
    event Deposit( address indexed sender, uint256 amt );
    
    struct Campaign {
        string campaignName;
        string campaignDesc;
        uint256 campaignGoal;       // in wei
        uint256 campaignDeadline;
        uint256 campaignRaised;
        bool campaignCompleted;         // in wei
 
    }
    
    uint256 public campaignID = 0;
    mapping (uint256 => Campaign) public campaigns;
    
    address private nftAddress;
    mapping (address => bool) public isDonor;
    
    //uint campaignRaised = 0;
    //bool isCompleted = false;
    
    function setNftAddress(address _addr) onlyOwner public {
        nftAddress = _addr;
    }
    
    function checkNftAddress() view public returns (address) {
        return nftAddress;
    }
    
    function newCampaign(
        string memory _campaignName, string memory _campaignDesc, 
        uint256 _campaignDeadline, uint256 _campaignGoal) public onlyOwner {
            
            require(bytes(_campaignName).length !=0 && bytes(_campaignDesc).length !=0, "Campaign name and description can't be empty!");
            require(_campaignGoal > 0, "Goal amount have to greather than zero !");
            
            campaignID +=1;
            uint campaignRaised = 0;
            bool isCompleted = false;
            /*
            Campaign storage camp = campaigns[campaignID];
            camp.campaignName = _campaignName;
            camp.campaignDesc = _campaignDesc;
            camp.campaignGoal = _campaignGoal;
            camp.campaignDeadline = _campaignDeadline + block.timestamp;
            */
            
            campaigns[campaignID] = Campaign(
                  _campaignName, _campaignDesc, _campaignGoal, _campaignDeadline + block.timestamp, campaignRaised, isCompleted);
        }

    function donatePlease(uint256 _campaignID) public payable {
        Campaign storage camp = campaigns[_campaignID];
        //emit Deposit(msg.sender, msg.value);
        require (block.timestamp < camp.campaignDeadline, "Campaign Failed!");
        require(camp.campaignRaised < camp.campaignGoal,"Goal achieved");
        require(msg.value > 0, 'Donation sholud be greather than zero.');
        
        //emit Deposit(msg.sender, msg.value);
        camp.campaignRaised = camp.campaignRaised +=  msg.value;
        
        if (camp.campaignRaised >= camp.campaignGoal) {
            camp.campaignCompleted = true;
            uint256 _amount = camp.campaignRaised - camp.campaignGoal;
            camp.campaignRaised -= _amount; 
            payable(msg.sender).call{value: _amount};
        }
        
        if (!isDonor[msg.sender]){
            isDonor[msg.sender] = true;
            NFT (nftAddress).mint(msg.sender);
        }
        
        emit Deposit(msg.sender, msg.value);
    }
    
    function ContractBalance() public view returns(uint) {
        return address(this).balance;
    }

}