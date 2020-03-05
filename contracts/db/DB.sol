pragma solidity ^0.6.0;

contract DB {

    struct Document {
        bytes32 id;
        address owner;
        uint versionCounter;
        mapping(uint => uint) data;
        mapping(uint => bool) warnings;
        mapping(uint => uint) timestamps;
    }
    mapping(bytes32 => Document) documents;

    mapping(uint => bytes32) documentNames;
    uint private documentNamesCounter;

    // store a document identified by `_documentId`
    function store(bytes32 _documentId, uint _data, bool _warning) public {

        documents[_documentId].data[documents[_documentId].versionCounter] = _data;
        documents[_documentId].warnings[documents[_documentId].versionCounter] = _warning;
        documents[_documentId].timestamps[documents[_documentId].versionCounter] = now;
        documents[_documentId].versionCounter++;
    }


    // create document entry and set it's ownership
    function setDocumentOwnership(bytes32 _documentId, address _owner) external {
        documents[_documentId] = Document(_documentId,_owner, 0);

        documentNames[documentNamesCounter] = _documentId;
        documentNamesCounter++;
    }

    function getDocumentOwnership(bytes32 _documentId) public view returns(address) {
        return documents[_documentId].owner;
    }

    // returns an array of the document data with warning flag set to false
    // `_documentid` to retrieve
    function getValidData(bytes32 _documentId) public view returns(uint[] memory){
        uint[] memory validDocuments;
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
}