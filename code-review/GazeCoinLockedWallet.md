# GazeCoinLockedWallet

Source file [../contracts/GazeCoinLockedWallet.sol](../contracts/GazeCoinLockedWallet.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


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
// Locked Wallet
// ----------------------------------------------------------------------------
contract GazeCoinLockedWallet is Owned {
    uint public lockedPeriod = 6 * 30 days;
    uint public lockedTo;

    event EthersWithdrawn(address indexed addr, uint ethers);
    event TokensWithdrawn(address indexed addr, address indexed tokenAddress, uint tokens);

    function GazeCoinLockedWallet() public {
        lockedTo = now + lockedPeriod;
    }
    function () public payable {
    }
    function withdrawSome(uint ethers) public onlyOwner {
        require(now > lockedTo);
        EthersWithdrawn(owner, ethers);
        owner.transfer(ethers);
    }
    function withdraw() public onlyOwner {
        require(now > lockedTo);
        EthersWithdrawn(owner, this.balance);
        owner.transfer(this.balance);
    }
    function withdrawSomeTokens(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        require(now > lockedTo);
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    function withdrawTokens(address tokenAddress) public onlyOwner returns (bool success) {
        require(now > lockedTo);
        uint balance = ERC20Interface(tokenAddress).balanceOf(this);
        return ERC20Interface(tokenAddress).transfer(owner, balance);
    }
}
```
