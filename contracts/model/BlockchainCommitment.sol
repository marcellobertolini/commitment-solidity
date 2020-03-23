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
        require(getState() == States.Null, "you can call this only during initialization");
        _;
        
    }

    modifier onlyParticipants (address _documentOwner){
        require(_documentOwner != address(0) && (_documentOwner == creditor || _documentOwner == debtor), "Document owner not valid");
        _;
    }

    // #### BEGIN INITIALIZATION METHODS ####

    // set the creditor and the debtor of the commitment
    function setActors(address _creditor, address _debtor) public onlyOwner onlyNull{

        //require(creditor == address(0), "Creditor can be set only once");
        require(_creditor != address(0), "Creditor cannot be null");
        //require(debtor == address(0), "Debtor can be set only once");
        require(_debtor != address(0), "Debtor cannot be null");

        creditor = _creditor;
        debtor = _debtor;
    }

    // set the document ownership. Only owners can update their documents
    function initDocument(string memory _documentId, address _documentOwner, string memory _documentType) public onlyOwner onlyNull onlyParticipants(_documentOwner) {
        require(checkDocumentType(_documentType), "Document type not valid");
        documentOwners[_documentId] = _documentOwner;
        documentTypes[_documentId] = getDocumentType(_documentType);
        onInitDocument(_documentId, _documentOwner);
    }

    // creditor and debtor can call this method to create/upload their documents
    function postDocument (string memory _documentId, uint _documentData) public {
        require(msg.sender == documentOwners[_documentId], "Document owner not valid");
        if(getState() == States.Null && documentTypes[_documentId] == DocumentType.START && !inCommitmentWin){
            inCommitmentWin=true;
            onDocumentPosted(_documentId, _documentData, false);
            onTargetStart();
        }
        else if(getState() == States.Conditional || getState() == States.Detached){

            if(documentTypes[_documentId] == DocumentType.END && !afterCommitmentWin){
                afterCommitmentWin=true;
                onDocumentPosted(_documentId, _documentData, false);
                onTargetEnds();
            }
            else if(documentTypes[_documentId] == DocumentType.SCOPE){
                onDocumentPosted(_documentId, _documentData, false);

            }
            
            else{
                onDocumentPosted(_documentId, _documentData, true);
                logWarning();

            }
        }
        else if(getState() == States.Violated && documentTypes[_documentId] == DocumentType.END && !afterCommitmentWin){
            onDocumentPosted(_documentId, _documentData, false);
            onTargetEnds();
        }
        else{
            onDocumentPosted(_documentId, _documentData, true);
            logWarning();
        }
        onTick();

    }

    function logWarning() private {
        if(warning == ControlFlowStatus.OK){
            warning = ControlFlowStatus.Warning;
        }
    }

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

    function onInitDocument(string memory _documentId, address _documentOwner) internal virtual;
    function onDocumentPosted(string memory _documentId, uint _documentData, bool _warning) internal virtual;
    
}