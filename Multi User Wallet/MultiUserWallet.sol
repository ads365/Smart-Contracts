pragma solidity ^0.4.0;

contract MultiUserWallet {
    
    address private _owner;
    
    mapping(address => uint8) private _owners;
    
    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }
    
    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }
    
    event DepositFunds(address from, uint amount);
    event WithdrawFunds(address from, uint amount);
    event TransferFunds(address from, address to, uint amount);
    
    function MultiSigWallet() public {
        _owner = msg.sender;
    }
    
    function addOwner(address newOwner) isOwner public {
        _owners[newOwner] = 1;
    }
    
    function removeOwner(address existingOwner) isOwner public {
        _owners[existingOwner] = 0;
    }
    
    function () public payable {
        DepositFunds(msg.sender, msg.value);
    }
    
    function withdraw(uint amount) validOwner public {
        require(address(this).balance >= amount);
        msg.sender.transfer(amount);
        WithdrawFunds(msg.sender, amount);
    }
    
    function transferTo(address to, uint amount) validOwner public {
        require(address(this).balance >= amount);
        to.transfer(amount);
        TransferFunds(msg.sender, to, amount);
    }
}
