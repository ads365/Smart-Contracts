pragma solidity ^0.4.0;

import "browser/ERC223Interface.sol";
import "browser/ERC223ReceivingContract.sol";
import "browser/SafeMath.sol";

contract ERC223Token is ERC223 {
    
    using SafeMath for uint;

    string public constant symbol = "E223T";
    string public constant name = "ERC223 Standard Token";
    uint public constant decimals = 18;
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
    
    //transfering to user account
    function transfer(address _to, uint _value) public returns (bool success) {
        if (_value > 0 && 
        _value <= __balanceOf[msg.sender] &&
        //ERC223 specific ensures it is not a contract account
        !isContract(_to)) {
            __balanceOf[msg.sender] -= _value;
            __balanceOf[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else{
            return false;
        }    
    }
    
    //ERC223 Specific for trnsferring tokens to an ERC223 recieving contract
    function transfer223(address _to, uint _value, bytes _data) public returns (bool success) {
        if (_value > 0 && 
            _value <= __balanceOf[msg.sender] &&
            isContract(_to)) {
                __balanceOf[msg.sender] -= _value;
                __balanceOf[_to] += _value;
                ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
                    _contract.tokenFallback(msg.sender, _value, _data);
                Transfer223(msg.sender, _to, _value, _data);
                return true;
        }
        else{
            return false;
        }    
    }
    
    function isContract(address _addr) public returns (bool success) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (__allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            __allowances[_from][msg.sender] >= _value &&
            __balanceOf[_from] >= _value) {
                __balanceOf[_from] -= _value;
                __balanceOf[_to] += _value;
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
