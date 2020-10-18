// File: contracts/utility/interfaces/IOracle.sol


pragma solidity 0.6.12;

interface IOracle {


    function getPrice() external returns(uint256 price);

}

// File: contracts/utility/interfaces/IOwned.sol


pragma solidity 0.6.12;


interface IOwned {
    function owner() external view returns (address);

    function transferOwnership(address _newOwner) external;
    function acceptOwnership() external;
}

// File: contracts/utility/Owned.sol


pragma solidity 0.6.12;



contract Owned is IOwned {
    address public override owner;
    address public newOwner;

    /**
      * @dev triggered when the owner is updated
      *
      * @param _prevOwner previous owner
      * @param _newOwner  new owner
    */
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
      * @dev initializes a new Owned instance
    */
    constructor() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        _ownerOnly();
        _;
    }

    // error message binary size optimization
    function _ownerOnly() internal view {
        require(msg.sender == owner, "ERR_ACCESS_DENIED");
    }

    /**
      * @dev allows transferring the contract ownership
      * the new owner still needs to accept the transfer
      * can only be called by the contract owner
      *
      * @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public override ownerOnly {
        require(_newOwner != owner, "ERR_SAME_OWNER");
        newOwner = _newOwner;
    }

    /**
      * @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() override public {
        require(msg.sender == newOwner, "ERR_ACCESS_DENIED");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// File: contracts/utility/PriceOracle.sol


pragma solidity 0.6.12;



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
