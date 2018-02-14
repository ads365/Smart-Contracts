pragma solidity ^0.4.0;

interface ERC223 {
    function totalSupply() public constant returns (uint _totalSupply);
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transfer223(address _to, uint _value, bytes data) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address _from, address _to, uint _value);
    event Transfer223(address _from, address _to, uint _value, bytes data);
    event Approval(address _owner, address _spender, uint _value);
}
