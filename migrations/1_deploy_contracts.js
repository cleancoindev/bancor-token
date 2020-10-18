/* eslint-env node */
/* global artifacts */


const BancorFormula = artifacts.require('./BancorFormula.sol');
const PriceOracle = artifacts.require('./PriceOracle.sol');
const BancorToken = artifacts.require('./BancorToken.sol');
const MockUSDTToken = artifacts.require('./ERC20Token.sol');


const Web3 = require("web3");
let BN = Web3.utils.BN;

//Mock USDT
const mockUSDTSupply = new BN(2000000).mul(new BN(10).pow(new BN(18))); //2000000USDT

//PriceOracle设置价格
const oraclePrice = new BN(100).mul(new BN(10).pow(new BN(16))); // 1USDT = 100BT

//BancorToken
const name = "BT";
const symbol = "BT";
const totalSupply = 0;
const decimals = 18;
let usdtAddress = "0x0000000000000000000000000000000000000000"; //TODO
const weight = 5000;

//BancorToken init
const contactManager = "0xe45217628722E522AdA72A2597cE8D8714395074";
const finacalManager = "0xe45217628722E522AdA72A2597cE8D8714395074";
const votePeriodblock = 2000;
const voteOpposeRate = 75;
const expectPrivateReserveToken = 1000;


module.exports = function (deployer, network, accounts) {

  const fromAccount = accounts[0];

  return deployer.deploy(BancorFormula, {
      from: fromAccount
    }).then(() => {
      return deployer.deploy(PriceOracle, {
        from: fromAccount
      })
    })
    .then(_oracle => {
      _oracle.setManualPrice(oraclePrice, {
        from: fromAccount
      });
    })
    .then(() => {

      return deployer.deploy(MockUSDTToken, "USDT", "USDT", 18, mockUSDTSupply, {
        from: fromAccount
      });

    })
    .then(() => {

      if (network === "kovan") {
        usdtAddress = MockUSDTToken.address;
      }

      return deployer.deploy(BancorToken, name, symbol, decimals, totalSupply, usdtAddress, weight, {
        from: fromAccount
      });
    })
    .then(_bancorToken => {
      _bancorToken.init(contactManager, finacalManager, PriceOracle.address, BancorFormula.address, votePeriodblock, voteOpposeRate, expectPrivateReserveToken, {
        from: fromAccount
      });
    }).then(() => {
      console.log("success");
    });
};
