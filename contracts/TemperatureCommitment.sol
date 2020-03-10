pragma solidity ^0.6.0;
import "./model/CMMNCommitment.sol";
import "./db/DB.sol";
contract TemperatureCommitment is CMMNCommitment {
    uint private temperatureLimit;
    DB db;
    constructor (uint _temperatureLimit) CMMNCommitment(Strenghts.Hard, Types.Persistent, 0, 0, 0, 0, RefCs.Detached) public {
        temperatureLimit = _temperatureLimit;
        db = new DB();

    }


    function evaluateConseguent() internal override returns(bool) {
        return db.isTemperatureValid(temperatureLimit);
    }

    function evaluateAntecedent() internal override returns(bool) {
        return db.exist("startDelivery", true);
    }

    function storeDocument(string memory _documentId, uint _documentData, bool _warning) internal override {
        db.store(_documentId, _documentData, _warning);
    }
    function setOwnership(string memory _documentId, address _documentOwner) internal override{
        db.setDocumentOwnership(_documentId, _documentOwner);
    }
    function getOwnership(string memory _documentId) internal view override returns(address) {
        return db.getDocumentOwnership(_documentId);
    }

    function getTerminateDocumentName() internal view override returns(string memory){
        return "endDelivery";
    }

    function getStartDocumentName() internal view override returns(string memory){
        return "startDelivery";
    }


}