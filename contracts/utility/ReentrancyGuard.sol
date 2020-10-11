// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;


contract ReentrancyGuard {

    bool private locked = false;


    constructor() internal {}

    modifier protected() {
        _protected();
        locked = true;
        _;
        locked = false;
    }

    function _protected() internal view {
        require(!locked, "ERROR_REETRANCY_GUARD");
    }
}
