/* eslint-env node, mocha */
/* global artifacts, contract, it, assert */

const undefined = artifacts.require('undefined');

let instance;

contract('undefined', (accounts) => {
  it('Should deploy an instance of the undefined contract', () => undefined.deployed()
    .then((contractInstance) => {
      instance = contractInstance;
    }));

  it('Should set the number', () => instance.setNumber(2, {
    from: accounts[0],
  }));

  it('Should get the number', () => instance.getNumber()
    .then((number) => {
      assert.equal(number.toNumber(), 2, 'Number is wrong!');
    }));
});
