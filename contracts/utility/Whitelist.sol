// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;
import "./Owned.sol";
import "./Utils.sol";
import "./interfaces/IWhitelist.sol";


contract Whitelist is IWhitelist, Owned, Utils {
    mapping (address => bool) private whitelist;


    event AddressAddition(address indexed _address);
    event AddressRemoval(address indexed _address);

    function isWhitelisted(address _address) public view override returns (bool) {
        return whitelist[_address];
    }


    function addAddress(address _address)
        ownerOnly
        validAddress(_address)
        public
    {
        if (whitelist[_address])
            return;

        whitelist[_address] = true;
        emit AddressAddition(_address);
    }


    function addAddresses(address[] memory _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddress(_addresses[i]);
        }
    }


    function removeAddress(address _address) ownerOnly public {
        if (!whitelist[_address])
            return;

        whitelist[_address] = false;
        emit AddressRemoval(_address);
    }


    function removeAddresses(address[] memory _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddress(_addresses[i]);
        }
    }
}
