pragma solidity ^0.4.0;

import "browser/ERC223ReceivingContract.sol";
import "browser/SafeMath.sol";
import "browser/ERC223Token.sol";

contract Crowdsale is ERC223ReceivingContract {
    
    using SafeMath for uint;
    
    ERC223Token private _token;
    
    uint private _start;
    uint private _end;
    
    uint private _price;
    
    uint private _limit;
    
    uint private _balance;
    
    mapping (address => uint) private _limits;
    
    modifier isValid() {
        require(block.number >= _start && block.number < _end);
        require(_balance > 0);
        _;
    }
    
    modifier isToken() {
        require(msg.sender == address(_token));
        _;
    }
    
    modifier withinLimits(address to, uint amount) {
        assert(amount > 0);
        amount = amount.div(_price);
        assert(_limit >= amount);
        assert(_limit >= _limits[to].add(amount));
        _;
    }
    
    event Buy(address beneficiary, uint amount);
    
    function Crowdsale(address token, uint start, uint end, uint price, uint limit) public {
        _token = ERC223Token(token);
        _start = start;
        _end = end;
        _price = price;
        _limit = limit;
    }
    
    function () public payable {
        revert();
    }
    
    function availableBalance() public view returns (uint) {
        return _balance;
    }
    
    function buy() public payable {
        buyFor(msg.sender);
    }
    
    //
    function buyFor(address beneficiary) public isValid withinLimits(beneficiary, msg.value) payable {
        uint amount = msg.value.div(_price);
        _token.transfer(beneficiary, amount);
        _balance = _balance.sub(amount);
        _limits[beneficiary] = _limits[beneficiary].add(amount);
        Buy(beneficiary, amount);
    }
    
    function tokenFallback(address, uint _value, bytes) public isToken {
        _balance = _balance.add(_value);
    }
}
