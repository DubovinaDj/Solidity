// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "./NFT.sol";

contract Donation is Ownable {
    
    event LogDeposit(address sender, uint amt);
    event LogRefund(address receiver, uint amt);
    
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
    mapping(address => uint) balances;
    
    //uint campaignRaised = 0;
    //bool isCompleted = false;
    
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

    function setNftAddress(address _addr) onlyOwner public {
        nftAddress = _addr;
    }
    
    function checkNftAddress() view public returns (address) {
        return nftAddress;
    }

    function donatePlease(uint256 _campaignID) public payable {
        Campaign storage camp = campaigns[_campaignID];
        
        require(block.timestamp < camp.campaignDeadline, "Campaign Failed!");
        require(camp.campaignRaised < camp.campaignGoal,"Goal achieved");
        require(msg.value > 0, 'Donation sholud be greather than zero.');
        
        balances[msg.sender] += msg.value;
        emit LogDeposit(msg.sender, msg.value);

        camp.campaignRaised = camp.campaignRaised +=  msg.value;
        
        if (camp.campaignRaised >= camp.campaignGoal) {
            camp.campaignCompleted = true;
            uint256 _returnAmount = camp.campaignRaised - camp.campaignGoal;
            camp.campaignRaised -= _returnAmount; 

            require(_returnAmount > 0);
            balances[msg.sender] -= _returnAmount;

            emit LogRefund(msg.sender, _returnAmount);
            payable(msg.sender).transfer(_returnAmount);            
        }
        
        if (!isDonor[msg.sender]){
            isDonor[msg.sender] = true;
            NFT (nftAddress).mint(msg.sender);
        }
    }
    
    function ContractBalance() public view returns(uint) {
        return address(this).balance;
    }

}