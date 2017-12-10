# GazeCoinCrowdsale

Source file [../contracts/GazeCoinCrowdsale.sol](../contracts/GazeCoinCrowdsale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// GazeCoin Crowdsale Contract
//
// Deployed to : {TBA}
//
// Note: Calculations are based on GZE having 18 decimal places
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for GazeCoin 2017. The MIT Licence.
// ----------------------------------------------------------------------------


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
// BokkyPooBah's Token Teleportation Service Interface v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
// BK Ok
contract BTTSTokenInterface is ERC20Interface {
    // BK Ok
    uint public constant bttsVersion = 100;

    // BK Next 5 Ok
    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    // BK Next 6 Ok - Events
    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);

    // BK Ok
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);

    // ------------------------------------------------------------------------
    // signed{X} functions
    // ------------------------------------------------------------------------
    // BK Next 3 Ok
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 3 Ok
    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 3 Ok
    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 3 Ok
    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 4 Ok
    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success);
    function unlockAccount(address tokenOwner) public;
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
    // BK Next block Ok
    enum CheckResult {
        Success,                           // 0 Success
        NotTransferable,                   // 1 Tokens not transferable yet
        AccountLocked,                     // 2 Account locked
        SignerMismatch,                    // 3 Mismatch in signing account
        AlreadyExecuted,                   // 4 Transfer already executed
        InsufficientApprovedTokens,        // 5 Insufficient approved tokens
        InsufficientApprovedTokensForFees, // 6 Insufficient approved tokens for fees
        InsufficientTokens,                // 7 Insufficient tokens
        InsufficientTokensForFees,         // 8 Insufficient tokens for fees
        OverflowError                      // 9 Overflow error
    }
}


// ----------------------------------------------------------------------------
// Bonus list interface
// ----------------------------------------------------------------------------
// BK Ok
contract BonusListInterface {
    // BK Ok
    mapping(address => uint) public bonusList;
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
// BK Ok
contract SafeMath {
    // BK Ok
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        c = a + b;
        // BK Ok
        require(c >= a);
    }
    // BK Ok
    function safeSub(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        require(b <= a);
        // BK Ok
        c = a - b;
    }
    // BK Ok
    function safeMul(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        c = a * b;
        // BK Ok
        require(a == 0 || c / a == b);
    }
    // BK Ok
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        require(b > 0);
        // BK Ok
        c = a / b;
    }
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
// GazeCoin Crowdsale Contract
// ----------------------------------------------------------------------------
// BK Ok
contract GazeCoinCrowdsale is SafeMath, Owned {

    // BK Ok
    BTTSTokenInterface public bttsToken;
    // BK Ok
    uint8 public constant TOKEN_DECIMALS = 18;

    // BK Ok
    address public wallet = 0x8cD8baa410E9172b949f2c4433D3b5905F8606fF;
    // BK Ok
    address public teamWallet = 0xb4eC550893D31763C02EBDa44Dff90b7b5a62656;
    // BK Ok
    uint public constant TEAM_PERCENT_GZE = 30;

    // BK Ok
    BonusListInterface public bonusList;
    // BK Next 3 Ok
    uint public constant TIER1_BONUS = 50;
    uint public constant TIER2_BONUS = 20;
    uint public constant TIER3_BONUS = 15;

    // Start 10 Dec 2017 11:00 EST => 10 Dec 2017 16:00 UTC => 11 Dec 2017 03:00 AEST
    // new Date(1512921600 * 1000).toUTCString() => "Sun, 10 Dec 2017 16:00:00 UTC"
    // BK Ok - new Date(1512921600 * 1000).toUTCString() => "Sun, 10 Dec 2017 16:00:00 UTC"
    uint public constant START_DATE = 1512921600;
    // End 21 Dec 2017 11:00 EST => 21 Dec 2017 16:00 UTC => 21 Dec 2017 03:00 AEST
    // new Date(1513872000 * 1000).toUTCString() => "Thu, 21 Dec 2017 16:00:00 UTC"
    // BK Ok - new Date(1513872000 * 1000).toUTCString() => "Thu, 21 Dec 2017 16:00:00 UTC"
    uint public endDate = 1513872000;

    // ETH/USD 9 Dec 2017 11:00 EST => 9 Dec 2017 16:00 UTC => 10 Dec 2017 03:00 AEST => 489.44 from CMC
    // BK Ok
    uint public usdPerKEther = 489440;
    // BK Ok
    uint public constant USD_CENT_PER_GZE = 35;
    // BK Ok
    uint public constant CAP_USD = 35000000;
    // BK Ok
    uint public constant MIN_CONTRIBUTION_ETH = 0.01 ether;

    // BK Next 3 Ok
    uint public contributedEth;
    uint public contributedUsd;
    uint public generatedGze;

    //  AUD 10,000 = ~ USD 7,500
    // BK Ok
    uint public lockedAccountThresholdUsd = 7500;
    // BK Ok
    mapping(address => uint) public accountEthAmount;

    // BK Ok
    bool public precommitmentAdjusted;
    // BK Ok
    bool public finalised;

    // BK Next 8 Ok - Events
    event BTTSTokenUpdated(address indexed oldBTTSToken, address indexed newBTTSToken);
    event WalletUpdated(address indexed oldWallet, address indexed newWallet);
    event TeamWalletUpdated(address indexed oldTeamWallet, address indexed newTeamWallet);
    event BonusListUpdated(address indexed oldBonusList, address indexed newBonusList);
    event EndDateUpdated(uint oldEndDate, uint newEndDate);
    event UsdPerKEtherUpdated(uint oldUsdPerKEther, uint newUsdPerKEther);
    event LockedAccountThresholdUsdUpdated(uint oldEthLockedThreshold, uint newEthLockedThreshold);
    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint accountEthAmount, uint usdAmount, uint gzeAmount, uint contributedEth, uint contributedUsd, uint generatedGze, bool lockAccount);

    // BK Ok - Constructor
    function GazeCoinCrowdsale() public {
    }
    // BK Ok - Only owner can execute
    function setBTTSToken(address _bttsToken) public onlyOwner {
        // BK Ok
        require(now <= START_DATE);
        // BK Ok - Log event
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        // BK Ok
        bttsToken = BTTSTokenInterface(_bttsToken);
    }
    // BK Ok - Only owner can execute
    function setWallet(address _wallet) public onlyOwner {
        // BK Ok - Log event
        WalletUpdated(wallet, _wallet);
        // BK Ok
        wallet = _wallet;
    }
    // BK Ok - Only owner can execute
    function setTeamWallet(address _teamWallet) public onlyOwner {
        // BK Ok - Log event
        TeamWalletUpdated(teamWallet, _teamWallet);
        // BK Ok
        teamWallet = _teamWallet;
    }
    // BK Ok - Only owner can execute
    function setBonusList(address _bonusList) public onlyOwner {
        require(now <= START_DATE);
        // BK Ok - Log event
        BonusListUpdated(address(bonusList), _bonusList);
        // BK Ok
        bonusList = BonusListInterface(_bonusList);
    }
    // BK Ok - Only owner can execute
    function setEndDate(uint _endDate) public onlyOwner {
        // BK Ok
        require(_endDate >= now);
        // BK Ok - Log event
        EndDateUpdated(endDate, _endDate);
        // BK Ok
        endDate = _endDate;
    }
    // BK Ok - Only owner can execute
    function setUsdPerKEther(uint _usdPerKEther) public onlyOwner {
        // BK Ok
        require(now <= START_DATE);
        // BK Ok - Log event
        UsdPerKEtherUpdated(usdPerKEther, _usdPerKEther);
        // BK Ok
        usdPerKEther = _usdPerKEther;
    }
    // BK Ok - Only owner can execute
    function setLockedAccountThresholdUsd(uint _lockedAccountThresholdUsd) public onlyOwner {
        // BK Ok
        require(now <= START_DATE);
        // BK Ok - Log event
        LockedAccountThresholdUsdUpdated(lockedAccountThresholdUsd, _lockedAccountThresholdUsd);
        // BK Ok
        lockedAccountThresholdUsd = _lockedAccountThresholdUsd;
    }

    // BK Next function Ok - View function
    function capEth() public view returns (uint) {
        return CAP_USD * 10**uint(3 + 18) / usdPerKEther;
    }
    // BK Next function Ok - View function
    function gzeFromEth(uint ethAmount, uint bonusPercent) public view returns (uint) {
        return usdPerKEther * ethAmount * (100 + bonusPercent) / 10**uint(3 + 2 - 2) / USD_CENT_PER_GZE;
    }
    // BK Next function Ok - View function
    function gzePerEth() public view returns (uint) {
        return gzeFromEth(10**18, 0);
    }
    // BK Next function Ok - View function
    function lockedAccountThresholdEth() public view returns (uint) {
        return lockedAccountThresholdUsd * 10**uint(3 + 18) / usdPerKEther;
    }
    // BK Next function Ok - View function
    function getBonusPercent(address addr) public view returns (uint bonusPercent) {
        uint tier = bonusList.bonusList(addr);
        if (tier == 1) {
            bonusPercent = TIER1_BONUS;
        } else if (tier == 2) {
            bonusPercent = TIER2_BONUS;
        } else if (tier == 3) {
            bonusPercent = TIER3_BONUS;
        } else {
            bonusPercent = 0;
        }
    }
    // BK Next function Ok - Payable
    function () public payable {
        // BK Ok - Normal contribution during period, owner can contribute 0.01 ETH at anytime. mint will fail when finalised
        require((now >= START_DATE && now <= endDate) || (msg.sender == owner && msg.value == MIN_CONTRIBUTION_ETH));
        // BK Ok
        require(contributedEth < capEth());
        // BK Ok
        require(msg.value >= MIN_CONTRIBUTION_ETH);
        // BK Ok
        uint bonusPercent = getBonusPercent(msg.sender);
        // BK Next 2 Ok
        uint ethAmount = msg.value;
        uint ethRefund = 0;
        // BK Ok
        if (safeAdd(contributedEth, ethAmount) > capEth()) {
            // BK Ok
            ethAmount = safeSub(capEth(), contributedEth);
            // BK Ok
            ethRefund = safeSub(msg.value, ethAmount);
        }
        // BK Ok
        uint usdAmount = safeDiv(safeMul(ethAmount, usdPerKEther), 10**uint(3 + 18));
        // BK Ok
        uint gzeAmount = gzeFromEth(ethAmount, bonusPercent);
        // BK Ok
        generatedGze = safeAdd(generatedGze, gzeAmount);
        // BK Ok
        contributedEth = safeAdd(contributedEth, ethAmount);
        // BK Ok
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        // BK Ok
        accountEthAmount[msg.sender] = safeAdd(accountEthAmount[msg.sender], ethAmount);
        // BK Ok
        bool lockAccount = accountEthAmount[msg.sender] > lockedAccountThresholdEth();
        // BK Ok
        bttsToken.mint(msg.sender, gzeAmount, lockAccount);
        // BK Ok
        if (ethAmount > 0) {
            // BK Ok
            wallet.transfer(ethAmount);
        }
        // BK Ok - Log event
        Contributed(msg.sender, ethAmount, ethRefund, accountEthAmount[msg.sender], usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze, lockAccount);
        // BK Ok
        if (ethRefund > 0) {
            // BK Ok
            msg.sender.transfer(ethRefund);
        }
    }

    // BK Ok - Only owner can execute
    function addPrecommitment(address tokenOwner, uint ethAmount, uint bonusPercent) public onlyOwner {
        // BK Ok
        require(!finalised);
        // BK Ok
        uint usdAmount = safeDiv(safeMul(ethAmount, usdPerKEther), 10**uint(3 + 18));
        // BK Ok
        uint gzeAmount = gzeFromEth(ethAmount, bonusPercent);
        // BK Ok
        uint ethRefund = 0;
        // BK Ok
        generatedGze = safeAdd(generatedGze, gzeAmount);
        // BK Ok
        contributedEth = safeAdd(contributedEth, ethAmount);
        // BK Ok
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        // BK Ok
        accountEthAmount[tokenOwner] = safeAdd(accountEthAmount[tokenOwner], ethAmount);
        // BK Ok
        bool lockAccount = accountEthAmount[tokenOwner] > lockedAccountThresholdEth();
        // BK Ok
        bttsToken.mint(tokenOwner, gzeAmount, lockAccount);
        // BK Ok - Log event
        Contributed(tokenOwner, ethAmount, ethRefund, accountEthAmount[tokenOwner], usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze, lockAccount);
    }
    // BK Ok - Only owner can execute, after the sale ends
    function addPrecommitmentAdjustment(address tokenOwner, uint gzeAmount) public onlyOwner {
        // BK Ok
        require(now > endDate || contributedEth >= capEth());
        // BK Ok
        require(!finalised);
        // BK Next 3 Ok
        uint ethAmount = 0;
        uint usdAmount = 0;
        uint ethRefund = 0;
        // BK Ok
        generatedGze = safeAdd(generatedGze, gzeAmount);
        // BK Ok
        bool lockAccount = accountEthAmount[tokenOwner] > lockedAccountThresholdEth();
        // BK Ok
        bttsToken.mint(tokenOwner, gzeAmount, lockAccount);
        // BK Ok
        precommitmentAdjusted = true;
        // BK Ok - Log event
        Contributed(tokenOwner, ethAmount, ethRefund, accountEthAmount[tokenOwner], usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze, lockAccount);
    }
    // BK Ok - Pure function
    function roundUp(uint a) public pure returns (uint) {
        // BK Ok
        uint multiple = 10**uint(TOKEN_DECIMALS);
        // BK Ok
        uint remainder = a % multiple;
        // BK Ok
        if (remainder > 0) {
            // BK Ok
            return safeSub(safeAdd(a, multiple), remainder);
        }
    }
    // BK Ok - Only owner can execute
    function finalise() public onlyOwner {
        // BK Ok
        require(!finalised);
        // BK Ok
        require(precommitmentAdjusted);
        // BK Ok
        require(now > endDate || contributedEth >= capEth());
        // BK Ok
        uint total = safeDiv(safeMul(generatedGze, 100), safeSub(100, TEAM_PERCENT_GZE));
        // BK Ok
        uint amountTeam = safeDiv(safeMul(total, TEAM_PERCENT_GZE), 100);
        // BK Ok
        generatedGze = safeAdd(generatedGze, amountTeam);
        // BK Ok
        uint rounded = roundUp(generatedGze);
        // BK Ok
        if (rounded > generatedGze) {
            // BK Ok
            uint dust = safeSub(rounded, generatedGze);
            // BK Ok
            generatedGze = safeAdd(generatedGze, dust);
            // BK Ok
            amountTeam = safeAdd(amountTeam, dust);
        }
        // BK Ok
        bttsToken.mint(teamWallet, amountTeam, false);
        // BK Ok
        bttsToken.disableMinting();
        // BK Ok
        finalised = true;
    }
}
```
