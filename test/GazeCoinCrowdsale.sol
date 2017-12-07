pragma solidity ^0.4.18;

// import "./BTTSTokenFactory.sol";

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
// BokkyPooBah's Token Teleportation Service Interface v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSTokenInterface is ERC20Interface {
    uint public constant bttsVersion = 100;

    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);

    // ------------------------------------------------------------------------
    // signed{X} functions
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public constant returns (CheckResult result);
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public constant returns (CheckResult result);
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public constant returns (CheckResult result);
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes data, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes data, uint fee, uint nonce, bytes sig, address feeAccount) public constant returns (CheckResult result);
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success);
    function unlockAccount(address tokenOwner) public;
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
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
contract BonusListInterface {
    mapping(address => uint) public bonusList;
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
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
// GazeCoin Crowdsale Contract
// ----------------------------------------------------------------------------
contract GazeCoinCrowdsale is SafeMath, Owned {

    BTTSTokenInterface public bttsToken;

    BonusListInterface public bonusList;
    uint public TIER1_BONUS = 20;
    uint public TIER2_BONUS = 15;

    address public wallet;
    address public lockedWallet;
    uint public lockedWalletUsdThreshold = 2000000;

    // Start 11 Dec 2017 11:00 EST. EST is 5 hours behind UTC, so 16:00 UTC
    // new Date(1512921600 * 1000).toUTCString() => "Sun, 10 Dec 2017 16:00:00 UTC"
    uint public START_DATE = 1512668285; // Thu  7 Dec 2017 17:38:05 UTC
    // End 21 Dec 2017 11:00 EST. EST is 5 hours behind UTC, so 16:00 UTC
    // new Date(1513872000 * 1000).toUTCString() => "Thu, 21 Dec 2017 16:00:00 UTC"
    uint public END_DATE = 1512668375; // Thu  7 Dec 2017 17:38:05 UTC

    uint public MIN_CONTRIBUTION_ETH = 0.01 ether;
    uint public CAP_USD = 35000000;
    // 05/12/2017 ETH/USD = 462.91
    uint public usdPerKEther = 462910;
    uint public USD_CENT_PER_GZE = 35;

    uint public contributedEth;
    uint public contributedUsd;
    uint public generatedGze;

    //  AUD 10,000 = ~ USD 7,600
    uint public lockedAccountThresholdUsd = 7600;

    address public TEAM = 0xa33a6c312D9aD0E0F2E95541BeED0Cc081621fd0;
    uint public TEAM_PERCENT = 30;

    bool public precommitmentAdjusted;
    bool public finalised;

    event BTTSTokenUpdated(address indexed oldBTTSToken, address indexed newBTTSToken);
    event BonusListUpdated(address indexed oldBonusList, address indexed newBonusList);
    event LockedAccountThresholdUsdUpdated(uint oldEthLockedThreshold, uint newEthLockedThreshold);
    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint usdAmount, uint gzeAmount, uint contributedEth, uint contributedUsd, uint generatedGze, bool lockAccount);

    function GazeCoinCrowdsale(address _wallet, address _lockedWallet) public {
        wallet = _wallet;
        lockedWallet = _lockedWallet;
    }
    function setBTTSToken(address _bttsToken) public onlyOwner {
        require(now <= START_DATE);
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        bttsToken = BTTSTokenInterface(_bttsToken);
    }
    function setBonusList(address _bonusList) public onlyOwner {
        require(now <= START_DATE);
        BonusListUpdated(address(bonusList), _bonusList);
        bonusList = BonusListInterface(_bonusList);
    }
    function setLockedAccountThresholdUsd(uint _lockedAccountThresholdUsd) public onlyOwner {
        require(now <= START_DATE);
        LockedAccountThresholdUsdUpdated(lockedAccountThresholdUsd, _lockedAccountThresholdUsd);
        lockedAccountThresholdUsd = _lockedAccountThresholdUsd;
    }

    function capEth() public view returns (uint) {
        return CAP_USD * 10**uint(3 + 18) / usdPerKEther;
    }
    function gzeFromEth(uint ethAmount, uint bonusPercent) public view returns (uint) {
        return usdPerKEther * ethAmount * (100 + bonusPercent) / 10**uint(3 + 2 - 2) / USD_CENT_PER_GZE;
    }
    function gzePerEth() public view returns (uint) {
        return gzeFromEth(10**18, 0);
    }
    function lockedWalletThresholdEth() public view returns (uint) {
        return lockedWalletUsdThreshold * 10**uint(3 + 18) / usdPerKEther;
    }
    function lockedAccountThresholdEth() public view returns (uint) {
        return lockedAccountThresholdUsd * 10**uint(3 + 18) / usdPerKEther;
    }

    function () public payable {
        require(now >= START_DATE && now <= END_DATE);
        require(contributedEth < capEth());
        require(msg.value >= MIN_CONTRIBUTION_ETH);
        uint tier = bonusList.bonusList(msg.sender);
        uint bonusPercent;
        if (tier == 1) {
            bonusPercent = TIER1_BONUS;
        } else if (tier == 2) {
            bonusPercent = TIER2_BONUS;
        } else {
            bonusPercent = 0;
        }
        uint ethAmount = msg.value;
        uint ethRefund = 0;
        if (safeAdd(contributedEth, ethAmount) > capEth()) {
            ethAmount = safeSub(capEth(), contributedEth);
            ethRefund = safeSub(msg.value, ethAmount);
        }
        uint walletEth;
        uint lockedWalletEth;
        if (contributedEth > lockedWalletThresholdEth()) {
            walletEth = 0;
            lockedWalletEth = ethAmount;
        } else if (safeAdd(contributedEth, ethAmount) > lockedWalletThresholdEth()) {
            lockedWalletEth = safeSub(safeAdd(contributedEth, ethAmount), lockedWalletThresholdEth());
            walletEth = ethAmount - lockedWalletEth;
        } else {
            walletEth = ethAmount;
            lockedWalletEth = 0;
        }
        uint usdAmount = safeDiv(safeMul(ethAmount, usdPerKEther), 10**uint(3 + 18));
        uint gzeAmount = gzeFromEth(ethAmount, bonusPercent);
        generatedGze = safeAdd(generatedGze, gzeAmount);
        contributedEth = safeAdd(contributedEth, ethAmount);
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        bool lockAccount = ethAmount > lockedAccountThresholdEth();
        bttsToken.mint(msg.sender, gzeAmount, lockAccount);
        if (walletEth > 0) {
            wallet.transfer(walletEth);
        }
        if (lockedWalletEth > 0) {
            lockedWallet.transfer(lockedWalletEth);
        }
        Contributed(msg.sender, ethAmount, ethRefund, usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze, lockAccount);
        if (ethRefund > 0) {
            msg.sender.transfer(ethRefund);
        }
    }

    function addPrecommitment(address tokenOwner, uint ethAmount, uint bonusPercent) public onlyOwner {
        require(now < START_DATE);
        require(!finalised);
        uint usdAmount = safeDiv(safeMul(ethAmount, usdPerKEther), 10**uint(3 + 18));
        uint gzeAmount = gzeFromEth(ethAmount, bonusPercent);
        uint ethRefund = 0;
        generatedGze = safeAdd(generatedGze, gzeAmount);
        contributedEth = safeAdd(contributedEth, ethAmount);
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        bool lockAccount = false;
        bttsToken.mint(tokenOwner, gzeAmount, lockAccount);
        Contributed(tokenOwner, ethAmount, ethRefund, usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze, lockAccount);
    }
    function addPrecommitmentAdjustment(address tokenOwner, uint gzeAmount) public onlyOwner {
        require(now > END_DATE || contributedEth >= capEth());
        require(!finalised);
        uint ethAmount = 0;
        uint usdAmount = 0;
        uint ethRefund = 0;
        generatedGze = safeAdd(generatedGze, gzeAmount);
        bool lockAccount = false;
        bttsToken.mint(tokenOwner, gzeAmount, lockAccount);
        precommitmentAdjusted = true;
        Contributed(tokenOwner, ethAmount, ethRefund, usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze, lockAccount);
    }
    function roundUp(uint a) public pure returns (uint) {
        uint multiple = 10**18;
        uint remainder = a % multiple;
        if (remainder > 0) {
            return safeSub(safeAdd(a, multiple), remainder);
        }
    }
    function finalise() public onlyOwner {
        require(!finalised);
        require(precommitmentAdjusted);
        require(now > END_DATE || contributedEth >= capEth());
        uint total = safeDiv(safeMul(generatedGze, 100), safeSub(100, TEAM_PERCENT));
        uint amountTeam = safeDiv(safeMul(total, TEAM_PERCENT), 100);
        generatedGze = safeAdd(generatedGze, amountTeam);
        bttsToken.mint(TEAM, amountTeam, false);
        uint rounded = roundUp(generatedGze);
        if (rounded > generatedGze) {
            uint dust = safeSub(rounded, generatedGze);
            generatedGze = safeAdd(generatedGze, dust);
            bttsToken.mint(wallet, dust, false);
        }
        bttsToken.disableMinting();
        finalised = true;
    }
}