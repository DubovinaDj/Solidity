// SPDX-License-Identifier: MIT;
pragma solidity ^0.8.3;

contract Donacija {
    
    address public admin;
    uint public raised;
    mapping(address => uint) public donators;
    uint public deadline;
    uint public goal;
    

    
    struct Kampanja {
        string description;
        string campName;
        bool completed;
        uint deadline;
        uint goal;
    }
    

   Kampanja[] public kampanje;
   
   
   

   //Postaviti pravila ugovora:
   constructor() {
       admin = msg.sender;
   }
   
   
  
  //Administrator samo moze da kreira kamapnju
  
    modifier created_admin {
        require(msg.sender == admin, "Samo admin moze da kreira kamapnju!");
        _;
    }
    
    function create(string memory _campName, string memory _description, uint _goal, uint _deadline) public created_admin {
        kampanje.push(Kampanja({campName: _campName, description: _description, goal: _goal, deadline: _deadline + block.timestamp, completed:false}));
    
    }
    
    //Kada je kampanja gotova dodaj flag true, samo admin moze da menja
    
    //function CampCompleted(uint _index) external created_admin {
   //     Kampanja storage kampanja = kampanje[_index];
   //     kampanja.completed = !kampanja.completed;
  //  }
    
    function CampCompleted() external view returns (bool completed) {
        if (goal == raised) {
            return true;
        }
    }
     
    //Refundiraj coine ako je prosa deadline, ako cilj nije ispunjen
    
    modifier kampanja_gotova {
        require(block.timestamp > deadline,"Kampanja je zavrsena !");
        _;
    }
    
    modifier nije_ispunjen_cilj {
        require(raised < goal,"Cilje nije ispunjen !");
        _;
    }
     
    function Vrati() public kampanja_gotova nije_ispunjen_cilj {
        
        payable(msg.sender).transfer(donators[msg.sender]);
        donators[msg.sender] = 0;
    }
    
    function donate() public payable {
        // uslov za izvrsavanje funkcije, ako uslov false, nece se izvrsiti transakcija
        require(block.timestamp < deadline);
        
        donators[msg.sender] += msg.value;
        raised += msg.value;
    }
}
