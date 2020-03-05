pragma solidity ^0.6.0;
import "./Commitment.sol";


abstract contract CMMNCommitment is Commitment {
    // store actors accounts
    address public debtor;
    address public creditor;
    address public owner;

    enum ControlFlowStatus {OK, Warning}
    ControlFlowStatus private warning;


    constructor (Strenghts _strenght, Types _cType, uint _minA, uint _maxA, uint _minC, uint _maxC, RefCs _refC) Commitment(_strenght, _cType, _minA, _maxA, _minC, _maxC, _refC) public {
        warning = ControlFlowStatus.OK;
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You cannot call this");
        _;
    }
    modifier onlyNull {
        if(state == States.Null){
            _;
        }
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
    function setDocumentOwnewship(bytes32[] memory _documentIds, address _documentOwner) public onlyOwner onlyNull{
        require(_documentOwner != address(0) && (_documentOwner == creditor || _documentOwner == debtor), "Document owner not valid");

        for(uint i = 0; i < _documentIds.length; i++){
            dbSetDocumentOwnership(_documentIds[i], _documentOwner);
        }


    }

    

    // #### END INITIALIZATION ####

    function start() public {
        onTargetStart();
    }

    // creditor and debtor can call this method to create/upload their documents
    function postDocument(bytes32 _documentId, uint _documentData) public {
        require(dbGetDocumentOwnership(_documentId) == msg.sender, "Only the document owner can update _documentId status");
        dbStoreDocument(_documentId, _documentData, false);
        onTick();


    }


    function dbStoreDocument(bytes32 _documentId, uint _documentData, bool _warning) internal virtual;
    function dbSetDocumentOwnership(bytes32 _documentId, address _documentOwner) internal virtual;
    function dbGetDocumentOwnership(bytes32 _documentId)internal virtual returns(address);


    

    
}