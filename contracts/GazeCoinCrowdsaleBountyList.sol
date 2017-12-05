pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// GazeCoin Crowdsale Bounty List
//
// Deployed to : 
//
// Enjoy.
//
// (c) GazeCoin 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {

    // ------------------------------------------------------------------------
    // Current owner, and proposed new owner
    // ------------------------------------------------------------------------
    address public owner;
    address public newOwner;

    // ------------------------------------------------------------------------
    // Constructor - assign creator as the owner
    // ------------------------------------------------------------------------
    function Owned() public {
        owner = msg.sender;
    }


    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by the owner
    // ------------------------------------------------------------------------
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    // ------------------------------------------------------------------------
    // Owner can initiate transfer of contract to a new owner
    // ------------------------------------------------------------------------
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }


    // ------------------------------------------------------------------------
    // New owner has to accept transfer of contract
    // ------------------------------------------------------------------------
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}


// ----------------------------------------------------------------------------
// Administrators, borrowed from Gimli
// ----------------------------------------------------------------------------
contract Administered is Owned {

    // ------------------------------------------------------------------------
    // Mapping of administrators
    // ------------------------------------------------------------------------
    mapping (address => bool) public administrators;

    // ------------------------------------------------------------------------
    // Add and delete adminstrator events
    // ------------------------------------------------------------------------
    event AdminstratorAdded(address adminAddress);
    event AdminstratorRemoved(address adminAddress);


    // ------------------------------------------------------------------------
    // Modifier for functions that can only be executed by adminstrator
    // ------------------------------------------------------------------------
    modifier onlyAdministrator() {
        require(administrators[msg.sender] || owner == msg.sender);
        _;
    }


    // ------------------------------------------------------------------------
    // Owner can add a new administrator
    // ------------------------------------------------------------------------
    function addAdministrators(address _adminAddress) public onlyOwner {
        administrators[_adminAddress] = true;
        AdminstratorAdded(_adminAddress);
    }


    // ------------------------------------------------------------------------
    // Owner can remove an administrator
    // ------------------------------------------------------------------------
    function removeAdministrators(address _adminAddress) public onlyOwner {
        delete administrators[_adminAddress];
        AdminstratorRemoved(_adminAddress);
    }
}


// ----------------------------------------------------------------------------
// Bounty list
// ----------------------------------------------------------------------------
contract GazeCoinCrowdsaleBountyList is Administered {

    // ------------------------------------------------------------------------
    // Administrators can add until sealed
    // ------------------------------------------------------------------------
    bool public sealed;

    // ------------------------------------------------------------------------
    // The whitelist, true for enabled, false for disabled
    // ------------------------------------------------------------------------
    mapping(address => bool) public bountyList;

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------
    event AddressListed(address indexed addr, bool enabled);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function GazeCoinCrowdsaleBountyList() public {
    }


    // ------------------------------------------------------------------------
    // Whitelist
    // ------------------------------------------------------------------------
    function enable(address[] addresses) public onlyAdministrator {
        require(!sealed);
        require(addresses.length != 0);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0);
            if (!bountyList[addresses[i]]) {
                bountyList[addresses[i]] = true;
                AddressListed(addresses[i], true);
            }
        }
    }


    // ------------------------------------------------------------------------
    // Disable whitelisting
    // ------------------------------------------------------------------------
    function disable(address[] addresses) public onlyAdministrator {
        require(!sealed);
        require(addresses.length != 0);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0);
            if (bountyList[addresses[i]]) {
                bountyList[addresses[i]] = false;
                AddressListed(addresses[i], false);
            }
        }
    }


    // ------------------------------------------------------------------------
    // After sealing, no more whitelisting is possible
    // ------------------------------------------------------------------------
    function seal() public onlyOwner {
        require(!sealed);
        sealed = true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ethers - no payable modifier
    // ------------------------------------------------------------------------
    function () public {
    }
}