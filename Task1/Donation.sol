// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

   // @title Create smart contract for donation platform
   // @author Djordje Dubovina
  //  @notice You can use this contract for only the most basic simulation
  //  @dev All function are implemented without side effects

import "@openzeppelin/contracts/access/Ownable.sol"; 

contract Donation is Ownable {
    
    //event Deposit( address indexed sender, uint256 amt );
    event LogDeposit(address sender, uint amt);
    event LogRefund(address receiver, uint amt);
    
    //mapping(address => uint256) donor;
        
    struct Campaign {
        string campaignName;
        string campaignDesc;
        uint256 campaignGoal;       // in wei
        uint256 campaignDeadline;
        bool campaignCompleted;
        uint256 campaignRaised;     // in wei
 
    }
    
    uint256 numCampaigns;
    mapping (uint256 => Campaign) public campaigns;
    address nftAddress;
    mapping(address => uint) balances;
    
    uint campaignRaised = 0;
    bool isCompleted = false;

  //  @notice Create new campaigns, every campaign have to contain: campaign name, description, goal
  //  @dev Only contract owner can create new camapigns
  //  @param campaignName, campaignDesc, campaignGoal, campaignDeadline, campaignCompleted, campaignRaised
  //  @return Created camapings   
    
    function newCampaign(
        string memory _campaignName, string memory _campaignDesc, 
        uint256 _campaignDeadline, uint256 _campaignGoal) onlyOwner public returns (uint256 campaignID) {
            
            require(bytes(_campaignName).length !=0 && bytes(_campaignDesc).length !=0, "Campaign name and description can't be empty!");
            require(_campaignGoal > 0, "Goal amount have to greather than zero !");
            
            campaignID = numCampaigns +=1;
            //Campaign storage camp = campaigns[campaignID];
            //camp.campaignName = _campaignName;
            //camp.campaignDesc = _campaignDesc;
           // camp.campaignGoal = _campaignGoal;
            //camp.campaignDeadline = _campaignDeadline + block.timestamp;
            
            
            campaigns[campaignID] = Campaign(
                  _campaignName, _campaignDesc, _campaignGoal, _campaignDeadline + block.timestamp, isCompleted, campaignRaised);
        }

  //  @notice If you want to donate please can choose ID of campaign
  // @dev If a raised amount is greater than the campaign goal after the transaction, the donor gets an excess of raised amount.
  //  @param campaignID
  //  @return Created campaigns with columns: campaignName(str), campaignDesc(str), campaignGoal(int), campaignDeadline(int), campaignCompleted(bool), campaignRaised(int)

    function donatePlease(uint256 _campaignID) public payable {
        Campaign storage camp = campaigns[_campaignID];
        
        require (block.timestamp < camp.campaignDeadline, "Campaign Failed!");
        require(camp.campaignRaised < camp.campaignGoal,"Goal achieved");
        require(msg.value > 0, 'Donation sholud be greather than zero.');
        
        balances[msg.sender] += msg.value;
        emit LogDeposit(msg.sender, msg.value);
        
        camp.campaignRaised = camp.campaignRaised +=  msg.value;
        
        if (camp.campaignRaised >= camp.campaignGoal) {
            camp.campaignCompleted = true;
            uint256 _amountRequested = camp.campaignRaised - camp.campaignGoal;
            camp.campaignRaised -= _amountRequested; 
            
            require(_amountRequested > 0);
            balances[msg.sender] -= _amountRequested;
            emit LogRefund(msg.sender, _amountRequested);
            payable(msg.sender).transfer(_amountRequested);
        }
    }
    
    function ContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    /*
    
    Etherscanu Ropsten contract link
    
    https://ropsten.etherscan.io/address/0x6808bf6c6424eb69201d6ff516ad3fd0279bec2b#code
    
    */   

}
