pragma solidity ^0.4.0;

contract Grade {
    
    mapping(address => Record[]) records;
    
    struct Record {
        address alumn;
        address registrar;
        uint mark;
        string signature;
    }
    
    function Grade() public {
        
    }
    
    function registerMark(address alumn, string signature, uint mark) public {
        records[alumn].push(Record(alumn, msg.sender, mark, signature));
    }
    
    function getNumSignatures() constant returns(uint) {
        return records[msg.sender].length;
    }
    
    function getSignature(uint index) returns(string) {
        Record[] alumnRecords = records[msg.sender];
        return alumnRecords[index].signature;
    }
    
    function getMark(uint index) public view returns(uint) {
        Record[] alumnRecords = records[msg.sender];
        return alumnRecords[index].mark;
    }
}
