pragma solidity ^0.4.0;

contract CustodialContract{
    
    address client;
    bool public _switch = false;
    
    event ClientDeposited(string _msg, uint _amount);
    event UserDeposited(address user, string _msg, uint _amount);
    event ClientWithdrew(string _msg);
    
    function CustodialContract() public {
        client = msg.sender;
    }
    
    modifier ifClient(){
        require(client == msg.sender);
        _;
    }
    
    function depositFunds() public payable {
        if(msg.sender != client) {
            UserDeposited(msg.sender, 'Has deposited', msg.value);
        }
        else {
            ClientDeposited('Client has deposited', msg.value);
        }
        
    }
    
    function withdrawFunds(uint amount) public ifClient {
        if(client.send(amount)) {
            _switch = true;
            ClientWithdrew('Client has withdrawn funds');
        }
        else{
            _switch = false;
        }
    }
    
    function getBalance() public ifClient constant returns(uint) {
        return this.balance;
    }
    
}
