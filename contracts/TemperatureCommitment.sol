pragma solidity ^0.6.0;
import "./model/BlockchainCommitment.sol";
import "./db/DB.sol";
contract TemperatureCommitment is BlockchainCommitment {
    uint private temperatureLimit;
    DB db;
    constructor (uint _temperatureLimit) BlockchainCommitment(Strenghts.Hard, Types.Persistent, 0, 0, 0, 0, RefCs.Detached) public {
        temperatureLimit = _temperatureLimit;
        db = new DB();

    }


    function condC() internal override returns(bool) {
        return db.isTemperatureValid(temperatureLimit);
    }

    function condA() internal override returns(bool) {
        return db.exist("startDelivery", true);
    }

    function logDocument(string memory _documentId, uint _documentData, bool _warning) internal override {
        db.store(_documentId, _documentData, _warning);
    }
    function initDocument(string memory _documentId, address _documentOwner) internal override{
        db.initDocument(_documentId, _documentOwner);
    }
    function getDocumentOwner(string memory _documentId) internal view override returns(address) {
        return db.getDocumentOwner(_documentId);
    }

    function getOnTargetEndsDocument() internal view override returns(string memory){
        return "endDelivery";
    }

    function getOnTargetStartsDocument() internal view override returns(string memory){
        return "startDelivery";
    }


}