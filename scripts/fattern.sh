#!/bin/bash

truffle-flattener contracts/bancor/BancorFormula.sol >fattern/BancorFormulaFlattener.sol
truffle-flattener contracts/token/BancorToken.sol >fattern/BancorTokenFlattener.sol
truffle-flattener contracts/utility/PriceOracle.sol >fattern/PriceOracleFlattener.sol

sed -i -e 's#// SPDX-License-Identifier: SEE LICENSE IN LICENSE##g' fattern/*.sol
