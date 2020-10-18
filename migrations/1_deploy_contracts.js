/* eslint-env node */
/* global artifacts */


const BancorToken = artifacts.require('BancorToken');

const BancorToken = artifacts.require('BancorToken');

const Web3 = require("web3");

module.exports = function (deployer, network, accounts) {
  const fromAccount = accounts[0];
  return deployer.deploy(DevPolyToken, {
    from: fromAccount
  }).then(() => {});
};
