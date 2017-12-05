pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// GazeCoin Crowdsale Bounty List
//
// Deployed to : 
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for GazeCoin 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// Admin
// ----------------------------------------------------------------------------
contract Admined is Owned {
    mapping (address => bool) public admins;

    event AdminAdded(address addr);
    event AdminRemoved(address addr);

    modifier onlyAdmin() {
        require(admins[msg.sender] || owner == msg.sender);
        _;
    }

    function addAdmin(address _addr) public onlyOwner {
        require(!admins[_addr]);
        admins[_addr] = true;
        AdminAdded(_addr);
    }
    function removeAdmin(address _addr) public onlyOwner {
        require(admins[_addr]);
        delete admins[_addr];
        AdminRemoved(_addr);
    }
}


// ----------------------------------------------------------------------------
// Bounty list
// ----------------------------------------------------------------------------
contract GazeCoinBountyList is Admined {
    bool public sealed;
    mapping(address => bool) public bountyList;

    event AddressListed(address indexed addr, bool enabled);

    function GazeCoinBountyList() public {
    }
    function enable(address[] addresses) public onlyAdmin {
        require(!sealed);
        require(addresses.length != 0);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0));
            if (!bountyList[addresses[i]]) {
                bountyList[addresses[i]] = true;
                AddressListed(addresses[i], true);
            }
        }
    }
    function disable(address[] addresses) public onlyAdmin {
        require(!sealed);
        require(addresses.length != 0);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0));
            if (bountyList[addresses[i]]) {
                bountyList[addresses[i]] = false;
                AddressListed(addresses[i], false);
            }
        }
    }
    function seal() public onlyOwner {
        require(!sealed);
        sealed = true;
    }
    function () public {
    }
}