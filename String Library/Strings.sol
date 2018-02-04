pragma solidity ^0.4.0;

library Strings {
    
    function concat(string _base, string _value) internal returns (string) {
        //convert value to bytes
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);
        
        string memory _tempValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tempValue);
        
        uint i;
        uint j;
        
        for(i=0; i<_baseBytes.length;i++) {
            _newValue[j++] = _baseBytes[i];
        }
        
        for(i=0; i<_valueBytes.length;i++) {
            _newValue[j++] = _valueBytes[i];
        }
        
        return string(_newValue);
    }
    
    //find target = "t" in example at its position within a string
    function stringPos(string _base, string _value) internal returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);
        
        assert(_valueBytes.length == 1);
        
        for(uint i =0; i<_baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }
        
        return -1;
    }
}

contract TestStrings {
    
    //applty library functionality to string data type
    using Strings for string;
    
    function TestCocat(string _base) public returns (string) {
        return _base.concat("_suffix");
        
    }
    
    //"t" as dummy
    function needleInHaystack(string _base) public returns (int) {
        return _base.stringPos("t");
    }
}
