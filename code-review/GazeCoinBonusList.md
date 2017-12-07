# GazeCoinBonusList

Source file [../contracts/GazeCoinBonusList.sol](../contracts/GazeCoinBonusList.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// GazeCoin Crowdsale Bonus List
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
// BK Ok
contract Owned {
    // BK Next 2 Ok
    address public owner;
    address public newOwner;

    // BK Ok - Event
    event OwnershipTransferred(address indexed _from, address indexed _to);

    // BK OK
    modifier onlyOwner {
        // BK OK
        require(msg.sender == owner);
        // BK OK
        _;
    }

    // BK OK - Constructor
    function Owned() public {
        // BK OK
        owner = msg.sender;
    }
    // BK OK - Only owner can execute
    function transferOwnership(address _newOwner) public onlyOwner {
        // BK OK
        newOwner = _newOwner;
    }
    // BK OK - Only new owner can execute
    function acceptOwnership() public {
        // BK OK
        require(msg.sender == newOwner);
        // BK OK
        OwnershipTransferred(owner, newOwner);
        // BK OK
        owner = newOwner;
        // BK OK
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// Admin
// ----------------------------------------------------------------------------
// BK OK
contract Admined is Owned {
    // BK OK
    mapping (address => bool) public admins;

    // BK Next 2 Ok - Events
    event AdminAdded(address addr);
    event AdminRemoved(address addr);

    // BK OK
    modifier onlyAdmin() {
        // BK OK
        require(admins[msg.sender] || owner == msg.sender);
        // BK OK
        _;
    }

    // BK OK - Only owner can execute
    function addAdmin(address _addr) public onlyOwner {
        // BK OK
        require(!admins[_addr]);
        // BK OK
        admins[_addr] = true;
        // BK OK - Log event
        AdminAdded(_addr);
    }
    // BK OK - Only owner can execute
    function removeAdmin(address _addr) public onlyOwner {
        // BK OK
        require(admins[_addr]);
        // BK OK
        delete admins[_addr];
        // BK OK - Log event
        AdminRemoved(_addr);
    }
}


// ----------------------------------------------------------------------------
// Bonus list - Tiers 1 and 2, with 0 as disabled
// ----------------------------------------------------------------------------
// BK OK
contract GazeCoinBonusList is Admined {
    // BK OK
    bool public sealed;
    // BK OK
    mapping(address => uint) public bonusList;

    // BK OK - Event
    event AddressListed(address indexed addr, uint tier);

    // BK OK - Constructor
    function GazeCoinBonusList() public {
    }
    // BK OK - Only admin can execute
    function add(address[] addresses, uint tier) public onlyAdmin {
        // BK OK
        require(!sealed);
        // BK OK
        require(addresses.length != 0);
        // BK OK
        for (uint i = 0; i < addresses.length; i++) {
            // BK OK
            require(addresses[i] != address(0));
            // BK OK
            if (bonusList[addresses[i]] == 0) {
                // BK OK
                bonusList[addresses[i]] = tier;
                // BK OK - Log event
                AddressListed(addresses[i], tier);
            }
        }
    }
    // BK OK - Only admin can execute
    function remove(address[] addresses) public onlyAdmin {
        // BK OK
        require(!sealed);
        // BK OK
        require(addresses.length != 0);
        // BK OK
        for (uint i = 0; i < addresses.length; i++) {
            // BK OK
            require(addresses[i] != address(0));
            // BK OK
            if (bonusList[addresses[i]] != 0) {
                // BK OK
                bonusList[addresses[i]] = 0;
                // BK OK - Log event
                AddressListed(addresses[i], 0);
            }
        }
    }
    // BK OK - Only owner can execute
    function seal() public onlyOwner {
        // BK OK
        require(!sealed);
        // BK OK
        sealed = true;
    }
    // BK OK - Not payable, so sending ETH will throw with full gas consumed
    function () public {
        // BK OK
        revert();
    }
}
```
