var TemperatureCommitment  = artifacts.require("./TemperatureCommitment.sol");

contract("TemperatureViolatedCommitment", (accounts) => {
    var cInstance;
    const ownerAccount = accounts[0];
    const creditorAccount = accounts[1];
    const debtorAccount = accounts[2];
    it("initialize actors", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            assert.equal(state, 0, "Commitment in Null state");
            
            // Setting participant creditor and debtor
            return cInstance.setActors(creditorAccount, debtorAccount, {from: accounts[0]});
        }).then(() => {
            return cInstance.creditor();
        }).then((_creditorAccount) => {
            assert.equal(_creditorAccount, creditorAccount, "Contains the correct creditor");
            return cInstance.debtor();
        }).then((_debtorAccount) => {
            assert.equal(_debtorAccount, debtorAccount, "Contains the correct debtor");
            return cInstance.signCommitment({ from : debtorAccount});
        }).then(() => {
            return cInstance.signCommitment({from : creditorAccount});
            
        });
    });

    // Initialization of the documents
    it("set documents", () => {
        
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.initDocument("startDelivery", debtorAccount, "InitScope",{from: ownerAccount});
        }).then(() => {
            return cInstance.initDocument("temperature", debtorAccount, "Scope", {from: ownerAccount});
        }).then(() => {
            return cInstance.initDocument("endDelivery", debtorAccount, "TerminateScope", {from: ownerAccount});
        }).then(() => {
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(state, 0, "Commitment remains in Null state");
        });
    });

    // Post InitScope document
    it("post initial document", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(state, 0, "commitment is Null state");
            return cInstance.postDocument("startDelivery", 0, {from: debtorAccount});
        })
        .then(() => {
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(state, 5, "commitment switches to Detached");
        });
    });

    // Post Scope document
    it("post temperature", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(state, 5, "commitment is in detached state before sending temperature");

            // Post temperature
            return cInstance.postDocument("temperature", 3, {from: debtorAccount});
        }).then(() => {
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(state, 5, "commitment is in detached state after sending temperature");
            
            // Post HIGH temperature
            return cInstance.postDocument("temperature", 10, {from: debtorAccount});
        }).then(() => {
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            
            assert.equal(state, 7, "commitment is marked violated");
        });
    });

    it("warning ok", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getWarning({from : ownerAccount});
        }).then((_warning) => {
            assert(!_warning, "warning ok");
        });
    });
});