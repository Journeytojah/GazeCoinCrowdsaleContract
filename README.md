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

## Deployment To Mainnet

* [ ] Deploy BTTSLibrary
* [ ] Deploy BTTSTokenFactory
* [ ] Deploy BTTSToken from BTTSTokenFactory
* [ ] Deploy GazeCoinCrowdsale
* [ ] Deploy GazeCoinBonusList
* [ ] GazeCoinCrowdsale.setBTTSToken(BTTSToken)
* [ ] GazeCoinCrowdsale.setBonusList(GazeCoinBonusList)
* [ ] BTTSToken.setMinter(GazeCoinCrowdsale)
* [ ] Check contract values
  * [ ] usdPerEther 489.44
  * [ ] gzePerEth 1398.40
  * [ ] gzePerEth +15% 1608.16
  * [ ] gzePerEth +20% 1678.08
  * [ ] gzePerEth +35% 1887.84
  * [ ] gzePerEth +50% 2097.60
* [ ] Send test transaction of 0.01 ETH from the contract owner account before start of crowdsale
  * [ ] Check tokens generated and ETH flow into multisig
* [ ] GazeCoinCrowdsale.addPrecommitment(tokenOwner, ethAmount, bonusPercent)
* [ ] GazeCoinBonusList.add([addresses, ...], tier)
  * Tier 1 +50%
  * Tier 2 +20%
  * Tier 3 +15%
* Crowdsale continues to end date or cap reached
* [ ] GazeCoinCrowdsale.addPrecommitmentAdjustment(tokenOwner, gzeAmount)
* [ ] GazeCoinCrowdsale.finalise()

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
* [x] [code-review/GazeCoinCrowdsale.md](code-review/GazeCoinCrowdsale.md)
  * [x] contract ERC20Interface
  * [x] contract BTTSTokenInterface is ERC20Interface
  * [x] contract BonusListInterface
  * [x] contract SafeMath
  * [x] contract Owned
  * [x] contract GazeCoinCrowdsale is SafeMath, Owned

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for GazeCoin - Dec 10 2017. The MIT Licence.
