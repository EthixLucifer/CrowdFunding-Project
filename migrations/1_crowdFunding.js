const crowdFunding = artifacts.require("crowdFunding");

module.exports = function (deployer) {
  deployer.deploy(crowdFunding);
};
