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
// Contracts that can have tokens approved, and then a function execute
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
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
    event MintingDisabled();
    event TransfersEnabled();

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

    function mint(address tokenOwner, uint tokens) public returns (bool success);
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
    enum CheckResult {
        Success,                           // 0 Success
        NotTransferable,                   // 1 Tokens not transferable yet
        SignerMismatch,                    // 2 Mismatch in signing account
        AlreadyExecuted,                   // 3 Transfer already executed
        InsufficientApprovedTokens,        // 4 Insufficient approved tokens
        InsufficientApprovedTokensForFees, // 5 Insufficient approved tokens for fees
        InsufficientTokens,                // 6 Insufficient tokens
        InsufficientTokensForFees,         // 7 Insufficient tokens for fees
        OverflowError                      // 8 Overflow error
    }
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

    address public wallet;

    // Start 11 Dec 2017 11:00 EST. EST is 5 hours behind UTC, so 16:00 UTC
    // new Date("2017-12-10T16:00:00").getTime()/1000 => 1512921600
    // new Date(1512921600 * 1000).toUTCString() => "Sun, 10 Dec 2017 16:00:00 UTC"
    uint public START_DATE = 1512279402; // Sun  3 Dec 2017 05:36:42 UTC

    // End 21 Dec 2017 11:00 EST. EST is 5 hours behind UTC, so 16:00 UTC
    // new Date("2017-12-21T16:00:00").getTime()/1000 => 1513872000
    // new Date(1513872000 * 1000).toUTCString() => "Thu, 21 Dec 2017 16:00:00 UTC"
    uint public END_DATE = 1512279597; // Sun  3 Dec 2017 05:36:42 UTC

    uint public ethMinContribution = 0.01 ether;

    uint public usdCap = 35000000;
    // 01/12/2017 ETH/USD = 444.05
    uint public usdPerKEther = 444050;
    uint public contributedEth;
    uint public contributedUsd;
    uint public generatedGze;
    BTTSTokenInterface public bttsToken;

    uint public usdCentPerGze = 35;

    uint public whitelistBonusPercent = 20;

    address public ADVISORS = 0xA88A05d2b88283ce84C8325760B72a64591279a2;
    address public TEAM = 0xa99A0Ae3354c06B1459fd441a32a3F71005D7Da0;
    address public CONTRACTORS = 0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756;
    address public USERGROWTHPOOL = 0xaBBa43E7594E3B76afB157989e93c6621497FD4b;
    uint public PERCENT_ADVISORS = 5;
    uint public PERCENT_TEAM = 10;
    uint public PERCENT_CONTRACTORS = 5;
    uint public PERCENT_USERGROWTHPOOL = 10;

    event BTTSTokenUpdated(address indexed oldBTTSToken, address indexed newBTTSToken);
    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint usdAmount, uint gzeAmount, uint contributedEth, uint contributedUsd, uint generatedGze);

    function GazeCoinCrowdsale(address _wallet) public {
        wallet = _wallet;
    }

    function setBTTSToken(address _bttsToken) public onlyOwner {
        // TODO require(now <= START_DATE);
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        bttsToken = BTTSTokenInterface(_bttsToken);
    }

    function ethCap() public view returns (uint) {
        return usdCap * 10**uint(3 + 18) / usdPerKEther;
    }

    function gzeFromEth(uint ethAmount, uint bonusPercent) public view returns (uint) {
        return usdPerKEther * ethAmount * (100 + bonusPercent) / 10**uint(3 + 2 - 2) / usdCentPerGze;
    }

    function gzePerEth() public view returns (uint) {
        return gzeFromEth(10**18, 0);
    }

    // 1GZE = US$0.35 = 0.35 / 444.050 ETH = 0.00078819952708 ETH
    // 1ETH = 444.05 / 0.35 GZE = 1268.714285714285714
    // gzePerKUsd = 1000 / 0.35 = 2857.142857142857143
    // gzePerKEth = usdPerKEther / 0.35 = 12687142.857142857142857

    function () public payable {
        require(now >= START_DATE && now <= END_DATE);
        require(contributedEth < ethCap());
        // require(!closed);
        // require(whitelist.whitelist(msg.sender) > 0 || picopsCertifier.certified(msg.sender));
        uint bonusPercent = 0; // or whitelistBonusPercent
        require(msg.value >= ethMinContribution);
        uint ethAmount = msg.value;
        uint ethRefund = 0;
        if (safeAdd(contributedEth, ethAmount) > ethCap()) {
            ethAmount = safeSub(ethCap(), contributedEth);
            ethRefund = safeSub(msg.value, ethAmount);
        }
        uint usdAmount = ethAmount * usdPerKEther / 10**uint(3 + 18);
        uint gzeAmount = gzeFromEth(ethAmount, bonusPercent);
        generatedGze = safeAdd(generatedGze, gzeAmount);
        contributedEth = safeAdd(contributedEth, ethAmount);
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        bttsToken.mint(msg.sender, gzeAmount);
        wallet.transfer(ethAmount);
        Contributed(msg.sender, ethAmount, ethRefund, usdAmount, gzeAmount, contributedEth, contributedUsd, generatedGze);
        if (ethRefund > 0) {
            msg.sender.transfer(ethRefund);
        }
    }

    function roundUp(uint a) public pure returns (uint) {
        uint multiple = 10**18;
        uint remainder = a % multiple;
        if (remainder > 0) {
            return safeSub(safeAdd(a, multiple), remainder);
        }
    }

    function finalise() public onlyOwner {
        uint percentToGenerate = safeAdd(PERCENT_ADVISORS, safeAdd(PERCENT_TEAM, safeAdd(PERCENT_CONTRACTORS, PERCENT_USERGROWTHPOOL)));
        uint total = safeDiv(safeMul(generatedGze, 100), safeSub(100, percentToGenerate));
        uint amountAdvisors = safeDiv(safeMul(total, PERCENT_ADVISORS), 100);
        generatedGze = safeAdd(generatedGze, amountAdvisors);
        bttsToken.mint(ADVISORS, amountAdvisors);
        uint amountTeam = safeDiv(safeMul(total, PERCENT_TEAM), 100);
        generatedGze = safeAdd(generatedGze, amountTeam);
        bttsToken.mint(TEAM, amountTeam);
        uint amountContractors = safeDiv(safeMul(total, PERCENT_CONTRACTORS), 100);
        generatedGze = safeAdd(generatedGze, amountContractors);
        bttsToken.mint(CONTRACTORS, amountContractors);
        uint amountUserGrowthPool = safeDiv(safeMul(total, PERCENT_USERGROWTHPOOL), 100);
        generatedGze = safeAdd(generatedGze, amountUserGrowthPool);
        bttsToken.mint(USERGROWTHPOOL, amountUserGrowthPool);
        // Round up
        uint rounded = roundUp(generatedGze);
        if (rounded > generatedGze) {
            uint dust = safeSub(rounded, generatedGze);
            generatedGze = safeAdd(generatedGze, dust);
            bttsToken.mint(wallet, dust);
        }
        if (contributedEth >= ethCap()) {
            // closed = true;
            bttsToken.disableMinting();
        }
    }
}