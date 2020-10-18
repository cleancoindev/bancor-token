// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

import "./interfaces/IOracle.sol";
import "./Owned.sol";

contract PriceOracle is IOracle, Owned {

    uint256 public manualPrice;

    constructor() public {}


    function getPrice() external override returns(uint256) {
        return manualPrice;
    }

    function setManualPrice(uint256 _price) public ownerOnly {
        manualPrice = _price;
    }


}
