pragma solidity ^0.6.0;
import "./Commitment.sol";


abstract contract BlockchainCommitment is Commitment {
    // store actors accounts
    address public debtor;
    address public creditor;

    bool private creditorApproved;
    bool private debtorApproved;

    enum ControlFlowStatus {OK, Warning}
    ControlFlowStatus private warning;

    address private owner;

    mapping(string => address) private documentOwners;


    enum DocumentCategory {INIT_SCOPE, TERMINATE_SCOPE, SCOPE}
    mapping(string => DocumentCategory) private documentCategories;


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

    modifier onlyParticipants (address _participant){
        require(_participant != address(0) && (_participant == creditor || _participant == debtor), "participant not valid");
        _;
    }

    modifier commitmentSigned() {
        require(creditorApproved && debtorApproved, "the commitment has not been signed yet");
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
        creates a new document and sets its cateogory.
        `_documentId`
        `_documentOwner` the owner of the document. Only actor that can upload the document in the future
        `_documentCategory` can be "InitScope", "Scope", "TerminateScope"
    */
    function initDocument(string memory _documentId, address _documentOwner, string memory _documentCategory) public onlyOwner onlyNull onlyParticipants(_documentOwner) {
        require(checkDocumentCategory(_documentCategory), "Document category not valid");
        documentOwners[_documentId] = _documentOwner;
        documentCategories[_documentId] = getDocumentCategory(_documentCategory);
        onInitDocument(_documentId, _documentOwner);
    }

    function signCommitment() public onlyParticipants(msg.sender) onlyNull{
        if (msg.sender == creditor){
            creditorApproved = true;
        }
        else if (msg.sender == debtor){
            debtorApproved = true;
        }
    }

    /* 
        The creditor and the debtor can call this method to create/upload their documents.
        This methods handles the commitment control flow with respect to the document type received.
        `_documentId` the document to post
        `_documentData` the document payload
    */ 
    function postDocument(string memory _documentId, uint _documentData) public commitmentSigned {
        require(msg.sender == documentOwners[_documentId], "Document owner not valid");
        if(!inCommitmentWin && documentCategories[_documentId] == DocumentCategory.INIT_SCOPE){
            inCommitmentWin = true;
            onDocumentPosted(_documentId, _documentData, false);
            onTargetStarts();

        }
        else if(inCommitmentWin && documentCategories[_documentId] == DocumentCategory.TERMINATE_SCOPE){
            inCommitmentWin = false;
            afterCommitmentWin = true;
            onDocumentPosted(_documentId, _documentData, false);
            onTargetEnds();

        }
        else if(inCommitmentWin && documentCategories[_documentId] == DocumentCategory.SCOPE){
            onDocumentPosted(_documentId, _documentData, false);
        }
        else {
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
        returns true if an error in the control flow was detected.
    */
    function getWarning() public view returns(bool){
        return warning == ControlFlowStatus.Warning;
    }

    function getDocumentCategory(string memory _documentType) private pure returns(DocumentCategory){
        bytes memory documentType = bytes(_documentType);
        bytes32 documentHash = keccak256(documentType);

        if(documentHash == keccak256("InitScope")){
            return DocumentCategory.INIT_SCOPE;
        }
        if(documentHash == keccak256("Scope")){
            return DocumentCategory.SCOPE;
        }
        if(documentHash == keccak256("TerminateScope")){
            return DocumentCategory.TERMINATE_SCOPE;
        }

    }

    function checkDocumentCategory(string memory _documentType) private pure returns(bool){
        bytes memory documentType = bytes(_documentType);
        bytes32 documentHash = keccak256(documentType);

        if(documentHash == keccak256("InitScope")){
            return true;
        }
        else if(documentHash == keccak256("Scope")){
            return true;
        }
        else if(documentHash == keccak256("TerminateScope")){
            return true;
        }
        else {
            return false;
        }
    }

    function isStarted() public view returns(bool){
        return inCommitmentWin;
    }
    function isTerminated() public view returns(bool){
        return afterCommitmentWin;
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