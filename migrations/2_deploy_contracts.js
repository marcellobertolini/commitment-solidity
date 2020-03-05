const Commitment = artifacts.require("TemperatureCommitment");
module.exports = (deployer) => {
    deployer.deploy(Commitment);
}