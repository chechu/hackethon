pragma solidity ^0.4.10;

contract Grade {
    
    mapping(address => Record[]) records;
    mapping(address => string[]) registrarToCenters;
    mapping(address => string[]) alumnToCenters;
    
    struct Record {
        address alumn;
        address registrar;
        string subject;
        uint mark;
    }
    
    function Grade() public {
        
    }
    
    function registerMark(address alumn, string subject, uint mark) public {
        string[] allowedCentersForRegistrar = registrarToCenters[msg.sender];
        string[] allowedCentersForAlumn = alumnToCenters[alumn];
        
        records[alumn].push(Record(alumn, msg.sender, subject, mark));
    }
    
    function getNumSubjects() constant returns(uint) {
        return records[msg.sender].length;
    }
    
    function getSubjects(uint index) returns(string) {
        Record[] alumnRecords = records[msg.sender];
        return alumnRecords[index].subject;
    }
    
    function getMark(uint index) public view returns(uint) {
        Record[] alumnRecords = records[msg.sender];
        return alumnRecords[index].mark;
    }
}

