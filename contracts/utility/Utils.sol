// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;


contract Utils {

    modifier greaterThanZero(uint256 _value) {
        _greaterThanZero(_value);
        _;
    }

    function _greaterThanZero(uint256 _value) internal pure {
        require(_value > 0, "ERR_ZERO_VALUE");
    }

    modifier validAddress(address _address) {
        _validAddress(_address);
        _;
    }

    function _validAddress(address _address) internal pure {
        require(_address != address(0), "ERR_INVALID_ADDRESS");
    }

    modifier notThis(address _address) {
        _notThis(_address);
        _;
    }

    function _notThis(address _address) internal view {
        require(_address != address(this), "ERR_ADDRESS_IS_SELF");
    }



}
