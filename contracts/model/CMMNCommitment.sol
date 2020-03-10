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
    
    // CANNOT PASS ARRAYS from client
    // set the document ownership. Only owners can update their documents
    //function setDocumentOwnewship(bytes32[] memory _documentIds, address _documentOwner) public onlyOwner onlyNull{
    //    require(_documentOwner != address(0) && (_documentOwner == creditor || _documentOwner == debtor), "Document owner not valid");
    //
    //    for(uint i = 0; i < _documentIds.length; i++){
    //        dbSetDocumentOwnership(_documentIds[i], _documentOwner);
    //    }


    //}

    // set the document ownership. Only owners can update their documents
    function setDocumentOwnewship(string memory _documentIds, address _documentOwner) public onlyOwner onlyNull{
        require(_documentOwner != address(0) && (_documentOwner == creditor || _documentOwner == debtor), "Document owner not valid");
        setOwnership(_documentIds, _documentOwner);
        


    }

    

    // #### END INITIALIZATION ####

    function updateTransitionVariables() internal override {
        Commitment.updateTransitionVariables();
        
        uint currentTime = now;
        if(maxA == 0){
            inAWin = currentTime >= timeCreation + minA;
            afterAWin = false;
        }
        if(maxC == 0){
            afterCWin = false;
            if(refC == RefCs.Detached){
                inCWin = currentTime >= timeDetach;
            }
            else {
                inCWin = currentTime >= timeCreation;
            }
        }
    }



    function start() public {
        onTargetStart();
    }
    function terminate() public {
        onTargetEnds();
    }

    // creditor and debtor can call this method to create/upload their documents
    function postDocument(string memory _documentId, uint _documentData) public {
        require(getOwnership(_documentId) == msg.sender, "Only the document owner can update _documentId status");
        // When conditional
        if(state == States.Conditional){
            // is the document that triggers to detached i.e. startDocument
            if(keccak256(abi.encode(_documentId)) == keccak256(abi.encode("startDelivery"))){
                storeDocument(_documentId, _documentData, false);
            }
            // any other document does not respect the control flow. Warning is logged
            else {
                storeDocument(_documentId, _documentData, true);
                logWarning();
            }
            onTick();
        }
        // When detached
        else if(state == States.Detached){
            // if it's posted a document belonging to the conditional stage
            if(keccak256(abi.encode(_documentId)) == keccak256(abi.encode(getStartDocumentName()))){
                storeDocument(_documentId, _documentData, true);
                logWarning();
                onTick();
            }
            // if it's a document that triggers the end of the detached state
            else if(keccak256(abi.encode(_documentId)) == keccak256(abi.encode(getTerminateDocumentName()))){
                storeDocument(_documentId, _documentData, false);
                onTargetEnds();
            }
            // any other valid documents
            else {
                storeDocument(_documentId, _documentData, false);
                onTick();
            }
        }
        // No document is expected
        else {
            storeDocument(_documentId, _documentData, true);
            logWarning();
            onTick();
        }

    }

    function logWarning() private {
        if(warning == ControlFlowStatus.OK){
            warning = ControlFlowStatus.Warning;
        }
    }

    function getWarning() public view returns(ControlFlowStatus){
        return warning;
    }

    function getTerminateDocumentName() internal view virtual returns(string memory);
    function getStartDocumentName() internal view virtual returns(string memory);

    function storeDocument(string memory _documentId, uint _documentData, bool _warning) internal virtual;
    function setOwnership(string memory _documentId, address _documentOwner) internal virtual;
    function getOwnership(string memory _documentId) internal view virtual returns(address);


    

    
}