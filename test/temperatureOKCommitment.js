const TemperatureCommitment  = artifacts.require("./TemperatureCommitment.sol");

contract("TemperatureSatisfiedCommitment", (accounts) => {
    const ownerAccount = accounts[0];
    const creditorAccount = accounts[1];
    const debtorAccount = accounts[2];

    var cInstance;

    it("init commitment", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;

            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(0, state, "Commitment in Null State");
            return cInstance.setActors(creditorAccount, debtorAccount, {from : ownerAccount});
        }).then(() => {
            return cInstance.creditor();
        }).then((_creditorAccount) => {
            assert.equal(creditorAccount, _creditorAccount, "creditor account set correctly");
            return cInstance.debtor();
        }).then((_debtorAccount) => {
            assert.equal(debtorAccount, _debtorAccount, "debtor account set correctly");

        });
    
    });

    it("set documents and start commitment" , () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.initDocument("startDelivery", debtorAccount, "start",{from: ownerAccount});
        }).then(() => {
            return cInstance.initDocument("temperature", debtorAccount, "scope", {from: ownerAccount});
        }).then(() => {
            return cInstance.initDocument("endDelivery", debtorAccount, "end", {from: ownerAccount});
        }).then(() => {
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(0, state, "Commitment remains in null state");
            
        });
    });

    it("post initial document", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(0, state, "commitment is in Null state");
            return cInstance.postDocument("startDelivery", 0, {from: debtorAccount});
        }).then(() => {
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(5, state, "commitment switches to Detached");
        });
    });


    it("post temperature", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(5, state, "commitment is in detached state");
            return cInstance.postDocument("temperature", 3, {from: debtorAccount});
        }).then(() => {
            return cInstance.postDocument("endDelivery", 0, {from: debtorAccount});
        }).then(() => {
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(6, state, "commitment is marked satisfied");
        });
    })
});