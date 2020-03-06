pragma solidity ^0.6.0;
import "./model/CMMNCommitment.sol";
import "./db/DB.sol";
contract TemperatureCommitment is CMMNCommitment {
    uint private temperatureLimit;
    DB private db;
    constructor (uint _temperatureLimit) CMMNCommitment(Strenghts.Hard, Types.Persistent, 0, 0, 0, 0, RefCs.Detached) public {
        temperatureLimit = _temperatureLimit;
        db = new DB();

    }

    function evaluateConseguent() internal override returns(bool) {
        uint[] memory temperatureData = db.getValidData("temperature");
        for(uint i = 0; i < temperatureData.length; i++){
            if(temperatureData[i] > temperatureLimit){
                return false;
            }
        }
        return true;
    }

    function evaluateAntecedent() internal override returns(bool) {
        uint[] memory startDelivery = db.getValidData("startDelivery");
        if(startDelivery.length == 1){
            return true;
        }
        return false;
    }

    function dbStoreDocument(bytes32 _documentId, uint _documentData, bool _warning) internal override {
        db.store(_documentId, _documentData, _warning);
    }
    function dbSetDocumentOwnership(bytes32 _documentId, address _documentOwner) internal override{
        db.setDocumentOwnership(_documentId, _documentOwner);
    }
    function dbGetDocumentOwnership(bytes32 _documentId)internal view override returns(address) {
        return db.getDocumentOwnership(_documentId);
    }

    function dbGetTerminateDocumentName() internal view override returns(bytes32){
        return "terminateDelivery";
    }
    function dbGetStartDocumentName() internal view override returns(bytes32){
        return "startDelivery";
    }
}