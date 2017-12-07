# GazeCoin Crowdsale Contract

## Summary

* [contracts/GazeCoinCrowdsaleWhitelist.sol](contracts/GazeCoinCrowdsaleWhitelist.sol) deployed to [0x73855EE8C390C5c6741e14c18F6017A5b877F428](https://etherscan.io/address/0x73855ee8c390c5c6741e14c18f6017a5b877f428#code).

<br />

<hr />

## Table Of Contents

<br />

<hr />

## Requirements

* White list to run from now until Dec 5th
* Whitelisters receive 20% bonus
* ICO runs from Dec 10-21 . Start times are 11am EST. 11am EST is 22:00 AEDT and 16:00 GMT.


<br />

<hr />

## Testing

<br />

<hr />

## Code Review

* [x] [code-review/GazeCoinBonusList.md](code-review/GazeCoinBonusList.md)
  * [x] contract Owned
  * [x] contract Admined is Owned
  * [x] contract GazeCoinBonusList is Admined
* [x] [code-review/GazeCoinLockedWallet.md](code-review/GazeCoinLockedWallet.md)
  * [x] contract ERC20Interface
  * [x] contract Owned
  * [x] contract GazeCoinLockedWallet is Owned
* [ ] [code-review/BTTSTokenFactory.md](code-review/BTTSTokenFactory.md)
  * [ ] contract ERC20Interface
  * [ ] contract ApproveAndCallFallBack
  * [ ] contract BTTSTokenInterface is ERC20Interface
  * [ ] library BTTSLib
  * [ ] contract BTTSToken is BTTSTokenInterface
  * [ ] contract Owned
  * [ ] contract BTTSTokenFactory is Owned
* [ ] [code-review/GazeCoinCrowdsale.md](code-review/GazeCoinCrowdsale.md)
  * [x] contract ERC20Interface
  * [x] contract BTTSTokenInterface is ERC20Interface
  * [x] contract BonusListInterface
  * [x] contract SafeMath
  * [x] contract Owned
  * [ ] contract GazeCoinCrowdsale is SafeMath, Owned

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for GazeCoin - Dec 02 2017. The MIT Licence.
