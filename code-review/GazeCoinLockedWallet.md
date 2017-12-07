# GazeCoinLockedWallet

Source file [../contracts/GazeCoinLockedWallet.sol](../contracts/GazeCoinLockedWallet.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
// BK Ok
contract ERC20Interface {
    // BK Next 6 Ok
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // BK Next 2 Ok - Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


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

    // BK Ok
    modifier onlyOwner {
        // BK Ok
        require(msg.sender == owner);
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function Owned() public {
        // BK Ok
        owner = msg.sender;
    }
    // BK Ok - Only owner can execute
    function transferOwnership(address _newOwner) public onlyOwner {
        // BK Ok
        newOwner = _newOwner;
    }
    // BK Ok - Only new owner can execute
    function acceptOwnership() public {
        // BK Ok
        require(msg.sender == newOwner);
        // BK Ok - Log event
        OwnershipTransferred(owner, newOwner);
        // BK Ok
        owner = newOwner;
        // BK Ok
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// Locked Wallet
// ----------------------------------------------------------------------------
// BK Ok
contract GazeCoinLockedWallet is Owned {
    // BK Ok
    uint public LOCKED_PERIOD = 6 * 30 days;
    // BK Ok
    uint public lockedTo;

    // BK Next 3 Ok - Events
    event EthersDeposited(address indexed addr, uint ethers);
    event EthersWithdrawn(address indexed addr, uint ethers);
    event TokensWithdrawn(address indexed addr, address indexed tokenAddress, uint tokens);

    // BK Ok - Constructor
    function GazeCoinLockedWallet() public {
        // BK Ok
        lockedTo = now + LOCKED_PERIOD;
    }
    // BK Ok - Will receive ETH
    function () public payable {
        // BK Ok
        EthersDeposited(msg.sender, msg.value);
    }
    // BK Ok - Only owner can execute
    function withdrawSome(uint ethers) public onlyOwner {
        // BK Ok
        require(now > lockedTo);
        // BK Ok - Log event
        EthersWithdrawn(owner, ethers);
        // BK Ok
        owner.transfer(ethers);
    }
    // BK Ok - Only owner can execute
    function withdraw() public onlyOwner {
        // BK Ok
        require(now > lockedTo);
        // BK Ok - Log event
        EthersWithdrawn(owner, this.balance);
        // BK Ok
        owner.transfer(this.balance);
    }
    // BK Ok - Only owner can execute
    function withdrawSomeTokens(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        // BK Ok
        require(now > lockedTo);
        // BK Ok - Log event
        TokensWithdrawn(owner, tokenAddress, tokens);
        // BK Ok
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    // BK Ok - Only owner can execute
    function withdrawTokens(address tokenAddress) public onlyOwner returns (bool success) {
        // BK Ok
        require(now > lockedTo);
        // BK Ok
        uint balance = ERC20Interface(tokenAddress).balanceOf(this);
        // BK Ok - Log event
        TokensWithdrawn(owner, tokenAddress, balance);
        // BK Ok
        return ERC20Interface(tokenAddress).transfer(owner, balance);
    }
}
```
