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

    function onDocumentPosted(string memory _documentId, uint _documentData, bool _warning) internal override {
        db.store(_documentId, _documentData, _warning);
    }
    function onInitDocument(string memory _documentId, address _documentOwner) internal override{
        db.initDocument(_documentId, _documentOwner);
    }




}