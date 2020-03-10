var TemperatureCommitment  = artifacts.require("./TemperatureCommitment.sol");

contract("TemperatureCommitment", (accounts) => {
    var cInstance;
    const creditorAddress = accounts[1];
    const debtorAddress = accounts[2];
    it("initialize actors", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            assert.equal(state, 0, "Commitment in Null state");
            return cInstance.setActors(creditorAddress, debtorAddress, {from: accounts[0]});
        }).then(() => {
            return cInstance.creditor();
        }).then((_creditorAdrress) => {
            assert.equal(_creditorAdrress, creditorAddress, "Contains the correct creditor");
            return cInstance.debtor();
        }).then((_debtorAddress) => {
            assert.equal(_debtorAddress, debtorAddress, "Contains the correct debtor");
        });
    });

    it("set documents", () => {
        
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.setDocumentOwnewship("startDelivery", debtorAddress, {from: accounts[0]});
        }).then(() => {
            return cInstance.setDocumentOwnewship("temperature", debtorAddress, {from: accounts[0]});
        }).then(() => {
            return cInstance.setDocumentOwnewship("endDelivery", debtorAddress, {from: accounts[0]});
        }).then(() => {
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            // 4 == Conditional
            assert.equal(state, 0, "Commitment remains in Null state");
        });
    });

    it("start the commitment", () => {
        
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.start({from: accounts[0]});
        }).then(() => {
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            assert.equal(state, 4, "Commitment switches to Conditional")
        })
    });

    

    it("post initial document", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            assert.equal(state, 4, "commitment is conditional state");
            return cInstance.condA();
            
        }).then((condA) => {
            assert(!condA, "Antecedent false");
            return cInstance.postDocument("startDelivery", 0, {from: debtorAddress});
        })
        .then(() => {
            return cInstance.condA();
        }).then((condA) => {
            assert(condA, "Antecedent true");
            return cInstance.inAWin();
        }).then((inAWin) => {
            assert(inAWin, "inAWin true");
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            assert.equal(state, 5, "commitment switches to Detached");
        });
    });


    it("post temperature", () => {
        return TemperatureCommitment.deployed().then((instance) => {
            cInstance = instance;
            return cInstance.getState({from : accounts[0]});
        }).then((state) => {
            assert.equal(state, 5, "commitment is in detached state before sending temperature");
            return cInstance.postDocument("temperature", 3, {from: debtorAddress});
        }).then(() => {
            return cInstance.condC();
        }).then((condC) => {
            assert(condC, "conseguent is valid after sending temperature");
            return cInstance.getState({from : accounts[0]});
        }).then((state) => {
            assert.equal(state, 5, "commitment is in detached state after sending temperature");
            return cInstance.postDocument("temperature", 10, {from: debtorAddress});
        }).then(() => {
            return cInstance.condC();
        }).then((condC) => {
            assert(!condC, "conseguent is false after sending wrong temperature");
            return cInstance.getState({from: accounts[0]});
        }).then((state) => {
            assert.equal(state, 7, "commitment is marked violated");
        });
    });
    

});