const TemperatureCommitment  = artifacts.require("./TemperatureCommitment.sol");

contract("TemperatureCommitment", (accounts) => {
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
            return cInstance.setDocumentOwnership("startDelivery", debtorAccount, {from: ownerAccount});
        }).then(() => {
            return cInstance.setDocumentOwnership("temperature", debtorAccount, {from: ownerAccount});
        }).then(() => {
            return cInstance.setDocumentOwnership("endDelivery", debtorAccount, {from: ownerAccount});
        }).then(() => {
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(0, state, "Commitment remains in null state");
            return cInstance.start({from : ownerAccount});
        }).then(()  => {
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(4, state, "Commitment switches to Conditional");
            
        });
    });

    it("post initial document", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(4, state, "commitment is in Conditional state");
            return cInstance.condA();
        }).then((condA) => {
            assert(!condA, "Antecedent false");
            return cInstance.postDocument("startDelivery", 0, {from: debtorAccount});
        }).then(() => {
            return cInstance.condA();
        }).then((condA) => {
            assert(condA, "Antecedent becomes true");
            return cInstance.inAWin();
        }).then((inAWin) => {
            assert(inAWin, "inAWin true");
            return cInstance.getState({from: ownerAccount});
        }).then((state) => {
            assert.equal(5, state, "commitment switches to detached");
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
            return cInstance.condC();
        }).then((condC) => {
            assert(condC, "Conseguent is valid");
            return cInstance.postDocument("endDelivery", 0, {from: debtorAccount});
        }).then(() => {
            return cInstance.getState({from : ownerAccount});
        }).then((state) => {
            assert.equal(6, state, "commitment is marked satisfied");
        });
    })
});