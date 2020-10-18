// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface IOracle {


    function getPrice() external returns(uint256 price);

}
