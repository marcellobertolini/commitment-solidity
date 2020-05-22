import TemperatureCommitment from "./artifacts/TemperatureCommitment.json";

const options = {
  web3: {
    block: false,
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:7545",
    },
  },
  contracts: [TemperatureCommitment],
};

export default options;