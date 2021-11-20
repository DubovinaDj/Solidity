/*
Napisati smart contract za platformu za donacije koristeci Remix IDE. 
Jedan Solidity file bice dovoljan. Administrator ima mogucnost da kreira nove kampanje. 
Svaka kampanja ima naziv, opis, vremenski i novcani cilj. 
Donacije se prihvataju samo u nativnom coinu. 
Deployovati smart contract na testnet po izboru (Rinkeby, Ropsten, Kovan, Goerli) i verifikovati isti na Etherscanu.
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "./NFT.sol";

contract Donation is Ownable {

    event Deposit( address indexed sender, uint256 amt );
    //event Sent(address from, address to, uint amnt); 
    
    /*
    struct Donator {
        address addr;
        uint256 amount;
    }
    
    mapping(address => uint256) donor;
    */    
    struct Campaign {
        string campaignName;
        string campaignDesc;
        uint256 campaignGoal;       // in wei
        uint256 campaignDeadline;
        uint256 campaignRaised;
        bool campaignCompleted;  // in wei
 
    }
    
    uint256 numCampaigns;
    mapping (uint256 => Campaign) public campaigns;
    
    address payable receiver;
    address private nftAddress;
    mapping (address => bool) donor;
    mapping (address => uint) public balances;
    
    //uint campaignRaised = 0;
    //bool isCompleted = false;
    
    function setNftAddress(address _addr) onlyOwner public {
        nftAddress = _addr;
    }
    
    function checkNftAddress() view public returns (address) {
        return nftAddress;
    }
    
    function setReceiverAddress(address _addr) onlyOwner public {
        receiver = payable(_addr);
    }
    
    function newCampaign(
        string memory _campaignName, string memory _campaignDesc, 
        uint256 _campaignDeadline, uint256 _campaignGoal) onlyOwner public returns (uint256 campaignID) {
            
            require(bytes(_campaignName).length !=0 && bytes(_campaignDesc).length !=0, "Campaign name and description can't be empty!");
            require(_campaignGoal > 0, "Goal amount have to greather than zero !");
            
            campaignID = numCampaigns +=1;
            bool isCompleted = false;
            uint campaignRaised = 0;
    
            //Campaign storage camp = campaigns[campaignID];
            //camp.campaignName = _campaignName;
            //camp.campaignDesc = _campaignDesc;
            //camp.campaignGoal = _campaignGoal;
            //camp.campaignDeadline = _campaignDeadline + block.timestamp;
            
            
            campaigns[campaignID] = Campaign(
                  _campaignName, _campaignDesc, _campaignGoal, _campaignDeadline + block.timestamp, campaignRaised, isCompleted);
        }
        
    error InsufficientBalance(uint requested, uint available);

    function donatePlease(uint256 _campaignID, uint amnt) public payable {
        Campaign storage camp = campaigns[_campaignID];
        //emit Deposit(msg.sender, msg.value);
        require (block.timestamp < camp.campaignDeadline, "Campaign Failed!");
        require(camp.campaignRaised < camp.campaignGoal,"Goal achieved");
        require(msg.value > 0, 'Donation sholud be greather than zero.');
        //require(balances[msg.sender] >= amnt);           
        
        
        if (amnt <= balances[msg.sender])
            revert InsufficientBalance({
                requested: amnt,
                available: balances[msg.sender]
            });
          
        balances[msg.sender] -= amnt;
        balances[receiver] += amnt;
        emit Deposit(msg.sender, amnt);
        
        //emit Deposit(msg.sender, msg.value);
        camp.campaignRaised = camp.campaignRaised +=  msg.value;
        
        if (camp.campaignRaised >= camp.campaignGoal) {
            camp.campaignCompleted = true;
            uint256 _amount = camp.campaignRaised - camp.campaignGoal;
            camp.campaignRaised -= _amount; 
            payable(msg.sender).call{value: _amount};
        }
        
        if (!donor[msg.sender]){
            donor[msg.sender] = true;
            Nft (nftAddress).mint(msg.sender);
        }
        
        //emit Deposit(msg.sender, msg.value);
    }
    
    function ContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    
}