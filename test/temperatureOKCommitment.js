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
            return cInstance.signCommitment({ from : debtorAccount});
        }).then(() => {
            return cInstance.signCommitment({from : creditorAccount});
        });
    
    });

    it("set documents and start commitment" , () => {
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
            return cInstance.isStarted({from : ownerAccount});
        }).then((_isStarted) => {
            assert(_isStarted, "commitment is started");
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(5, state, "commitment switches to Detached");
        });
    });


    it("post temperature", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.postDocument("temperature", 3, {from: debtorAccount});
        }).then(() => {
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(5, state, "commitment is in detached state");
        });
    });

    it("post endDelivery", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.postDocument("endDelivery", 0, {from : debtorAccount});
        }).then(() => {
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(6, state, "commitment is marked satisfied");
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

    it("commitment terminated", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.isTerminated({from : ownerAccount});
        }).then((_isTerminated) => {
            assert(_isTerminated, "commitment is terminated");
        });
    });

    
});