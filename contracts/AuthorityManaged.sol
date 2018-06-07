pragma solidity ^0.4.23;

/// @title AuthorityManaged - Provides support and utilities for contract ownership

contract AuthorityManaged {
    address owner;
    address newOwner;

    /**
    
    */
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
        constructor
    */
    function contractor() public {
        owner = msg.sender;
    }

    /**
        allows execution by the owner only
    */
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

    /**
        allows transfering the contract ownership 
        the new owner still needs to accept the transfer
        can only be called by the contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
        new owner can use to accept an ownership transfer
     */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
