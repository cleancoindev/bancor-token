/* eslint-env node */
/* global artifacts */

const BancorToken = artifacts.require('BancorToken');

function deployContracts(deployer) {
  deployer.deploy(BancorToken);
}

module.exports = deployContracts;
