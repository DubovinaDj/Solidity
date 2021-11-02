// Flattener

pragma solidity ^0.8.0;



contract Donation is Ownable {
    
    address public immutable ADMIN;
    
    struct Campaign {               // grouped attributes
        string name;
        string description;
        uint duration;
        uint goal;
        uint raised;
        bool completed;
    }
    
    
    mapping(uint => Campaign) public campaigns;        //mapping from uint to Campaign attributes (id to Campaign)
    uint256 campaignIndex = 0;
    
    constructor() {
        ADMIN = payable(msg.sender);        
    }
    
    modifier onlyAdmin {
        require(msg.sender == ADMIN, "Only admin can call this function");
        _;
    }
    
    
    // Create campaign (only Admin can create campaigns)
    function createCampaign(
        string memory _name, string memory _description, 
        uint _duration, uint _goal
        ) public onlyAdmin {
            
            bool completed = false;
            uint raised = 0;
            campaignIndex += 1;
            
            campaigns[campaignIndex] = Campaign(_name, _description, _duration + block.timestamp, _goal, raised, completed);
            
        }
    
    
    //Function for donation 
    function donate(uint _index) public payable {
        
        require (block.timestamp < campaigns[_index].duration, "Campaign Failed!");
        require(campaigns[_index].raised < campaigns[_index].goal,"Goal achieved");
        
        campaigns[_index].raised += msg.value;
        
        if (campaigns[_index].raised + msg.value > campaigns[_index].goal) {     
            
            uint _amount =  campaigns[_index].raised - campaigns[_index].goal;
            campaigns[_index].raised -= _amount;
            campaigns[_index].completed = true;
            payable(msg.sender).call{value: _amount};
        } else if (campaigns[_index].raised == campaigns[_index].goal) campaigns[_index].completed = true;
        
    }

}
