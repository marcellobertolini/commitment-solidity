pragma solidity ^0.6.0;
import "./Commitment.sol";


abstract contract BlockchainCommitment is Commitment {
    // store actors accounts
    address public debtor;
    address public creditor;
    enum ControlFlowStatus {OK, Warning}
    ControlFlowStatus private warning;

    address private owner;

    mapping(string => address) private documentOwners;


    enum DocumentType {START, END, SCOPE}
    mapping(string => DocumentType) private documentTypes;


    bool private inCommitmentWin;
    bool private afterCommitmentWin;


    constructor (Strenghts _strenght, Types _cType, uint _minA, uint _maxA, uint _minC, uint _maxC, RefCs _refC) Commitment(_strenght, _cType, _minA, _maxA, _minC, _maxC, _refC) public {
        warning = ControlFlowStatus.OK;
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "you cannot call this");
        _;
    }


    modifier onlyNull {
        require(super.getState() == States.Null, "you can call this only during initialization");
        _;
        
    }

    modifier onlyParticipants (address _documentOwner){
        require(_documentOwner != address(0) && (_documentOwner == creditor || _documentOwner == debtor), "Document owner not valid");
        _;
    }



    /*
        This method must be called when the smart contract is instantiated.
        Sets the addresses of the two actors of the commitment
    */
    function setActors(address _creditor, address _debtor) public onlyOwner onlyNull{

        //require(creditor == address(0), "Creditor can be set only once");
        require(_creditor != address(0), "Creditor cannot be null");
        //require(debtor == address(0), "Debtor can be set only once");
        require(_debtor != address(0), "Debtor cannot be null");

        creditor = _creditor;
        debtor = _debtor;
    }

    /*
        creates a new document and sets its type.
        `_documentId`
        `_documentOwner` the owner of the document. Only actor that can upload the document in the future
        `_documentType` can be "start", "scope", "end"
    */
    function initDocument(string memory _documentId, address _documentOwner, string memory _documentType) public onlyOwner onlyNull onlyParticipants(_documentOwner) {
        require(checkDocumentType(_documentType), "Document type not valid");
        documentOwners[_documentId] = _documentOwner;
        documentTypes[_documentId] = getDocumentType(_documentType);
        onInitDocument(_documentId, _documentOwner);
    }

    /* 
        The creditor and the debtor can call this method to create/upload their documents.
        This methods handles the commitment control flow with respect to the document type received.
        `_documentId` the document to post
        `_documentData` the document payload
    */ 
    function postDocument (string memory _documentId, uint _documentData) public {
        require(msg.sender == documentOwners[_documentId], "Document owner not valid");
        if(super.getState() == States.Null && documentTypes[_documentId] == DocumentType.START && !inCommitmentWin){
            inCommitmentWin=true;
            onDocumentPosted(_documentId, _documentData, false);
            super.onTargetStarts();
        }
        else if(super.getState() == States.Conditional || super.getState() == States.Detached){

            if(documentTypes[_documentId] == DocumentType.END && !afterCommitmentWin){
                afterCommitmentWin=true;
                onDocumentPosted(_documentId, _documentData, false);
                super.onTargetEnds();
            }
            else if(documentTypes[_documentId] == DocumentType.SCOPE){
                onDocumentPosted(_documentId, _documentData, false);

            }
            
            else{
                onDocumentPosted(_documentId, _documentData, true);
                logWarning();

            }
        }
        else if(super.getState() == States.Violated && documentTypes[_documentId] == DocumentType.END && !afterCommitmentWin){
            onDocumentPosted(_documentId, _documentData, false);
            super.onTargetEnds();
        }
        else{
            onDocumentPosted(_documentId, _documentData, true);
            logWarning();
        }
        super.onTick();

    }
    /*
        This method is called whenever a document is received out of the
        commitment scope.
    */
    function logWarning() private {
        if(warning == ControlFlowStatus.OK){
            warning = ControlFlowStatus.Warning;
        }
    }
    /*
        returns {ControlflowStatus.Warning} if an error in the control flow was detected.
    */
    function getWarning() public view returns(ControlFlowStatus){
        return warning;
    }

    function getDocumentType(string memory _documentType) private pure returns(DocumentType){
        bytes memory documentType = bytes(_documentType);
        bytes32 documentHash = keccak256(documentType);

        if(documentHash == keccak256("start") || documentHash == keccak256("Start")){
            return DocumentType.START;
        }
        if(documentHash == keccak256("scope") || documentHash == keccak256("Scope")){
            return DocumentType.SCOPE;
        }
        if(documentHash == keccak256("end") || documentHash == keccak256("End")){
            return DocumentType.END;
        }

    }

    function checkDocumentType(string memory _documentType) private pure returns(bool){
        bytes memory documentType = bytes(_documentType);
        bytes32 documentHash = keccak256(documentType);

        if(documentHash == keccak256("start") || documentHash == keccak256("Start")){
            return true;
        }
        else if(documentHash == keccak256("scope") || documentHash == keccak256("Scope")){
            return true;
        }
        else if(documentHash == keccak256("end") || documentHash == keccak256("End")){
            return true;
        }
        else {
            return false;
        }
    }

    /*
        This method is called when the owner of the smart cotract creates a document on the smart contract.
        `_documentId` is the document identifier
        '_documentOwner' is the address that has the right to upload the relative document in the future.
    */
    function onInitDocument(string memory _documentId, address _documentOwner) internal virtual;

    /*
        This method is called when an actor uploads the document identified by
        `_documentId`. 
        `_documentData` is the document payload.
        `_warning` is set to true if the document is received out of the commitment scope
    */
    function onDocumentPosted(string memory _documentId, uint _documentData, bool _warning) internal virtual;
    
}