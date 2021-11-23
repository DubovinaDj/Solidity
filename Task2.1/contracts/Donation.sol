// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Create smart contract for donation platform
/// @author Djordje Dubovina
/// @notice You can use this contract for donation platform simulation

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
        uint256 campaignRaised;     // in wei
        bool campaignCompleted;    
 
    }
    
    uint256 numCampaigns;
    mapping (uint256 => Campaign) public campaigns;
    
    address private nftAddress;
    mapping (address => bool) donor;
    mapping(address => uint) balances;

    uint campaignRaised = 0;
    bool isCompleted = false;

    /// @notice Create new campaigns, every campaign have to contain: campaign name, description, goal
    /// @dev Only contract owner can create new camapigns
    /// @param campaignName, campaignDesc, campaignGoal, campaignDeadline, campaignCompleted, campaignRaised
    /// @return Created camapings 
    
    function newCampaign(
        string memory _campaignName, string memory _campaignDesc, 
        uint256 _campaignDeadline, uint256 _campaignGoal) onlyOwner public returns (uint256 campaignID) {
            
            require(bytes(_campaignName).length !=0 && bytes(_campaignDesc).length !=0, "Campaign name and description can't be empty!");
            require(_campaignGoal > 0, "Goal amount have to greather than zero !");
            
            campaignID = numCampaigns +=1;
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

    /// @notice set address of NFT.sol contract. Only contract owner set address
    /// @param _addr

    function setNftAddress(address _addr) onlyOwner public {
        nftAddress = _addr;
    }
    
    /// @notice check NFT.sol contract address
    /// @param _addr
    /// @return address 

    function checkNftAddress() view public returns (address) {
        return nftAddress;
    }

    /// @notice If you want to donate please can choose ID of campaign
    /// @dev If a raised amount is greater than the campaign goal after the transaction, the donor gets an excess of raised amount.
    /// @param campaignID
    /// @return Created campaigns with columns: campaignName(str), campaignDesc(str), campaignGoal(int), campaignDeadline(int), campaignCompleted(bool), campaignRaised(int)

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
            //payable(msg.sender).transfer(_returnAmount);
            (bool sent, ) = msg.sender.call{value: _returnAmount}("");
            require(sent, "Failed to send Ether");          
        }
        
        if (!donor[msg.sender]){
            donor[msg.sender] = true;
            NFT (nftAddress).mint(msg.sender);
        }
    }
    
    /// @notice check balance of the contract
    /// @return  address

    function ContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    /*
    Etherscan Ropsten links:

    Donation contract
    https://ropsten.etherscan.io/address/0x3cD0E8433dd2BFcdcf5b8B3dFF99165161dD2FBE#code
    
    NFT contract
    https://ropsten.etherscan.io/address/0xb3Df860886FE1491BFA229EAFBfb903b395CdB62#code
    */
}

