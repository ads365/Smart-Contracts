pragma solidity ^0.4.0;

import "browser/ERC20Interface.sol";
import "browser/SafeMath.sol";

contract ERC20Token is ERC20 {
    
    using SafeMath for uint;
    
    string public constant symbol = "E20T";
    string public constant name = "ERC20 Standard Token";
    uint8 public constant decimals = 18;
    uint public constant __totalSupply = 10000000;
    
    //balances of addresses stored here
    mapping (address => uint) private __balanceOf;
    
    //allowances of addresses stored here
    mapping (address => mapping (address => uint)) private __allowances;
    
    //initial publisher of contract has whole token supply
    function ERC20Token() public {
        __balanceOf[msg.sender] = __totalSupply;
    }
    
    function totalSupply() public constant returns (uint _totalSupply) {
        _totalSupply = __totalSupply;
    }
    
    function balanceOf(address _addr) public constant returns (uint balance) {
        return __balanceOf[_addr];
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        if (_value > 0 && _value <= balanceOf(msg.sender)) {
            __balanceOf[msg.sender] = __balanceOf[msg.sender].sub(_value);
            __balanceOf[_to] = __balanceOf[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else{
            return false;
        }    
    }
    
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (__allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            __allowances[_from][msg.sender] >= _value &&
            __balanceOf[_from] >= _value) {
                __balanceOf[_from] = __balanceOf[_from].sub(_value);
                __balanceOf[_to] = __balanceOf[_to].add(_value);
                __allowances[_from][msg.sender] -= _value;
                Transfer(_from, _to, _value);
                return true;
            }
            else{
                return false;
            }
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        __allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return __allowances[_owner][_spender];
    }
    
}
