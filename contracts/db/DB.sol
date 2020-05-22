pragma solidity ^0.5.0;

contract DB {

    struct Document {
        string id;
        address owner;
        uint versionCounter;
        mapping(uint => uint) data;
        mapping(uint => bool) warnings;
        mapping(uint => uint) timestamps;
    }
    mapping(string => Document) documents;

    mapping(uint => string) documentNames;
    uint private documentNamesCounter;

    address private dbOwner;

    constructor() public {
        dbOwner = msg.sender;
    }


    modifier onlyDbOwner() {
        require(msg.sender==dbOwner, "Only dbOwner can call this");
        _;
    }

    // store a document identified by `_documentId`
    function store(string memory _documentId, uint _data, bool _warning) public onlyDbOwner{

        documents[_documentId].data[documents[_documentId].versionCounter] = _data;
        documents[_documentId].warnings[documents[_documentId].versionCounter] = _warning;
        documents[_documentId].timestamps[documents[_documentId].versionCounter] = now;
        documents[_documentId].versionCounter++;
    }


    // create document entry and set it's ownership
    function initDocument(string memory _documentId, address _owner) public onlyDbOwner{
        documents[_documentId] = Document(_documentId,_owner, 0);
        documents[_documentId].warnings[documents[_documentId].versionCounter] = true;

        documentNames[documentNamesCounter] = _documentId;
        documentNamesCounter++;
    }

    function getDocumentOwner(string memory _documentId) public view onlyDbOwner returns(address) {
        return documents[_documentId].owner;
    }

    // returns an array of the document data with warning flag set to false
    // `_documentid` to retrieve
    function getValidData(string memory _documentId) private view onlyDbOwner returns(uint[] memory){
        uint[] memory validDocuments = new uint[](documents[_documentId].versionCounter);
        uint index;
        // for each document version
        for(uint i = 0; i < documents[_documentId].versionCounter; i++){
            // add the document if it is valid
            if(!documents[_documentId].warnings[i]){
                validDocuments[index] = documents[_documentId].data[i];
                index++;
            }
        }
        return validDocuments;
    }

    function exist(string memory _documentId, bool _unique) public view onlyDbOwner returns(bool){
        uint counter;

        for(uint i = 0; i < documents[_documentId].versionCounter; i++){
            if(!documents[_documentId].warnings[i]){
                counter++;
            }
        }
        if(_unique && counter > 1){
            return false;
        }
        else {
            return counter >= 1;
        }
    }

    function isTemperatureValid(uint _temperatureLimit) public view onlyDbOwner returns(bool) {
        uint[] memory temperatureData = getValidData("temperature");
        for(uint i = 0; i < temperatureData.length; i++){
            if(temperatureData[i] > _temperatureLimit){
                return false;
            }
        }
        return true;
    }

    function getDocument(string memory _documentId, uint _version) public onlyDbOwner view returns(bool){
        Document storage doc = documents[_documentId];
        //uint d = doc.data[_version];
        bool w = doc.warnings[_version];
        //uint t = doc.timestamps[_version];

        return w;
    }
}