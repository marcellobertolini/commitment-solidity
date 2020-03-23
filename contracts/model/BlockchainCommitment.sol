pragma solidity ^0.6.0;
import "./Commitment.sol";


abstract contract BlockchainCommitment is Commitment {
    // store actors accounts
    address public debtor;
    address public creditor;
    enum ControlFlowStatus {OK, Warning}
    ControlFlowStatus private warning;

    address private owner;

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
    function setDocument(string memory _documentIds, address _documentOwner) public onlyOwner onlyNull{
        require(_documentOwner != address(0) && (_documentOwner == creditor || _documentOwner == debtor), "Document owner not valid");
        initDocument(_documentIds, _documentOwner);
        


    }



    function start() public {
        onTargetStart();
    }
    function terminate() public {
        onTargetEnds();
    }

    // creditor and debtor can call this method to create/upload their documents
    function postDocument (string memory _documentId, uint _documentData) public {
        require(msg.sender == getDocumentOwner(_documentId), "Document owner not valid");
        if(getState() == States.Null && keccak256(abi.encode(_documentId)) == keccak256(abi.encode(getOnTargetStartsDocument())) && !inCommitmentWin){
            inCommitmentWin=true;
            logDocument(_documentId, _documentData, false);
            onTargetStart();
        }
        else if(getState() == States.Conditional || getState() == States.Detached){

            if(keccak256(abi.encode(_documentId)) == keccak256(abi.encode(getOnTargetEndsDocument())) && !afterCommitmentWin){
                afterCommitmentWin=true;
                logDocument(_documentId, _documentData, false);
                onTargetEnds();
            }
            else if(keccak256(abi.encode(_documentId)) != keccak256(abi.encode(getOnTargetStartsDocument())) && keccak256(abi.encode(_documentId)) != keccak256(abi.encode(getOnTargetEndsDocument()))){
                logDocument(_documentId, _documentData, false);

            }
            
            else{
                logDocument(_documentId, _documentData, true);
                logWarning();

            }
        }
        else if(getState() == States.Violated && keccak256(abi.encode(_documentId)) == keccak256(abi.encode(getOnTargetEndsDocument())) && !afterCommitmentWin){
            logDocument(_documentId, _documentData, false);
            onTargetEnds();
        }
        else{
            logDocument(_documentId, _documentData, true);
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

    function getOnTargetEndsDocument() internal view virtual returns(string memory);
    function getOnTargetStartsDocument() internal view virtual returns(string memory);

    function logDocument(string memory _documentId, uint _documentData, bool _warning) internal virtual;
    function initDocument(string memory _documentId, address _documentOwner) internal virtual;
    function getDocumentOwner(string memory _documentId) internal view virtual returns(address);


    

    
}