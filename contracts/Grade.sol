pragma solidity ^0.4.10;

contract Grade {
    
    address owner = msg.sender;
    mapping(address => Record[]) records;
    mapping(address => string[]) registrarToCenters;
    mapping(address => string[]) alumnToCenters;
    
    enum RecordState {Valid, Refuted}
    
    struct Record {
        uint creationTime;
        uint lastUpdateTime;
        
        address alumn;
        string subject;
        uint mark;
        address registrar;
        
        RecordState state;
    }
    
    event markAdded(address alumn, uint recordIndex);
    event refutedMark(address alumn, uint recordIndex);
    event validatedMark(address alumn, uint recordIndex);
    
    modifier onlyBy(address account) {
        require(account == msg.sender);
        _;
    }
    
    function Grade() public {
        
    }
    
    /*
     * It adds a new registrar to the center. Only the owner of the contract (as a superadmin) can do this.
     */
    function addRegistrarToCenter(address registrar, string center) public onlyBy(owner) {
        registrarToCenters[registrar].push(center);
    }
    
    /*
     * It adds a new alumn to the center. Only a valid registrar of the center can do this.
     */
    function addAlumnToCenter(address alumn, string center) public {
        require(registrarCanAddAlumn(msg.sender, center));

        alumnToCenters[alumn].push(center);
    }
    
    /*
     * It adds a new record for the alumn, in the subject, with the passed mark.
     * The register will be the sender of the message.
     */
    function registerMark(address alumn, string subject, uint mark) public {
        require(registarCanRegisterMarkAlumn(msg.sender, alumn));
        uint creationTime = now;
        records[alumn].push(Record(creationTime, creationTime, alumn, subject, mark, msg.sender, RecordState.Valid));
        
        markAdded(alumn, records[alumn].length - 1);
    }
    
    /*
     * It allows to mark as refuted a record by the alumn of the record.
     */
    function refuteMark(uint recordIndex) public {
        require(alumnCanRefuteRecord(msg.sender, recordIndex));
        records[msg.sender][recordIndex].state = RecordState.Refuted;
        records[msg.sender][recordIndex].lastUpdateTime = now;
        
        refutedMark(msg.sender, recordIndex);
    }
    
    /*
     * It allows to mark as valid a refuted record by a allowed registrar.
     */
    function validateMark(address alumn, uint recordIndex) public {
        require(registrarCanValidateRecord(msg.sender, alumn, recordIndex));
        records[alumn][recordIndex].state = RecordState.Valid;
        records[alumn][recordIndex].lastUpdateTime = now;
        
        validatedMark(alumn, recordIndex);
    }
    
    /*
     * It returns the number of alumn's records (sender of the message) in the contract
     */
    function getNumRecords() constant returns(uint) {
        return records[msg.sender].length;
    }
    
    /*
     * It returns the name of the subject associated with the record whose index is passed as parameter
     */
    function getRecordSubject(uint recordIndex) public view returns(string) {
        Record[] alumnRecords = records[msg.sender];
        require(alumnRecords.length > 0 && recordIndex >= 0 && recordIndex < alumnRecords.length);
        
        return alumnRecords[recordIndex].subject;
    }
    
    /*
     * It returns the mark of the subject associated with the record whose index is passed as parameter
     */
    function getRecordMark(uint recordIndex) public view returns(uint) {
        Record[] alumnRecords = records[msg.sender];
        require(alumnRecords.length > 0 && recordIndex >= 0 && recordIndex < alumnRecords.length);

        return alumnRecords[recordIndex].mark;
    }
    
    /*
     * It returns the creation time of the record whose index is passed as parameter
     */
    function getRecordCreationTime(uint recordIndex) public view returns(uint) {
        Record[] alumnRecords = records[msg.sender];
        require(alumnRecords.length > 0 && recordIndex >= 0 && recordIndex < alumnRecords.length);

        return alumnRecords[recordIndex].creationTime;
    }
    
    /*
     * It returns the last update time of the record whose index is passed as parameter
     */
    function getRecordLastUpdateTime(uint recordIndex) public view returns(uint) {
        Record[] alumnRecords = records[msg.sender];
        require(alumnRecords.length > 0 && recordIndex >= 0 && recordIndex < alumnRecords.length);

        return alumnRecords[recordIndex].lastUpdateTime;
    }
    
    /*
     * It returns the state of the record whose index is passed as parameter
     */
    function getRecordState(uint recordIndex) public view returns(uint) {
        Record[] alumnRecords = records[msg.sender];
        require(alumnRecords.length > 0 && recordIndex >= 0 && recordIndex < alumnRecords.length);

        return uint(alumnRecords[recordIndex].state);
    }
    
    /*
     * The registrar must belong to any univerity where the alumn is signed
     */
    function registarCanRegisterMarkAlumn(address registrar, address alumn) private returns(bool) {
        string[] allowedCentersForRegistrar = registrarToCenters[registrar];
        string[] allowedCentersForAlumn = alumnToCenters[alumn];
        
        for(uint i = 0; i < allowedCentersForRegistrar.length; i++) {
            for(uint j = 0; j < allowedCentersForAlumn.length; j++) {
                if(keccak256(allowedCentersForRegistrar[i]) == keccak256(allowedCentersForAlumn[j])) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    function registrarCanAddAlumn(address registrar, string center) returns(bool) {
        string[] allowedCentersForRegistrar = registrarToCenters[registrar];

        for(uint i = 0; i < allowedCentersForRegistrar.length; i++) {
            if(keccak256(allowedCentersForRegistrar[i]) == keccak256(center)) {
                return true;
            }
        }
        
        return false;
    }
    
    function alumnCanRefuteRecord(address alumn, uint recordIndex) returns(bool) {
        Record[] alumnRecords = records[alumn];
        return (recordIndex >= 0 && recordIndex < alumnRecords.length && 
        alumnRecords.length > 0 && alumnRecords[recordIndex].state == RecordState.Valid);
    }
    
    /*
     * The registrar must be who added the refuted register in the past.
     */
    function registrarCanValidateRecord(address registrar, address alumn, uint recordIndex) returns(bool) {
        Record[] alumnRecords = records[alumn];
        return (recordIndex >= 0 && recordIndex < alumnRecords.length && 
        alumnRecords.length > 0 && 
        alumnRecords[recordIndex].registrar == registrar &&
        alumnRecords[recordIndex].state == RecordState.Refuted);
    }
}

