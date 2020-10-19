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


//BancorToken startPrivatePlacement
const privatePeriodBlock = 800000;
const votePeriodblock = 2000;
const voteOpposeRate = 75;
const expectPrivateReserveToken = 1000;


module.exports = async function (deployer, network, accounts) {

  const fromAccount = accounts[0];
  let options = {
    from: fromAccount
  };

  await deployer.deploy(BancorFormula, options);

  await deployer.deploy(PriceOracle, options);

  let _oracle = await PriceOracle.deployed();
  await _oracle.setManualPrice(oraclePrice, options);

  await deployer.deploy(MockUSDTToken, "USDT", "USDT", 18, mockUSDTSupply, options);

  if (network === "kovan") {
    usdtAddress = MockUSDTToken.address;
  }

  await deployer.deploy(BancorToken, name, symbol, decimals, totalSupply, usdtAddress, weight, options);

  let _bancorToken = await BancorToken.deployed();

  await _bancorToken.init(contactManager, finacalManager, PriceOracle.address, BancorFormula.address, options);

  await _bancorToken.startPrivatePlacement(privatePeriodBlock, votePeriodblock, voteOpposeRate, expectPrivateReserveToken, options);

};
