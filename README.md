# GazeCoin Crowdsale Contract

Status: Crowdsale contracts live. This page to be updated when I'm refreshed!

<br />

## Summary

* [contracts/GazeCoinCrowdsaleWhitelist.sol](contracts/GazeCoinCrowdsaleWhitelist.sol) deployed to [0x73855EE8C390C5c6741e14c18F6017A5b877F428](https://etherscan.io/address/0x73855ee8c390c5c6741e14c18f6017a5b877f428#code).

<br />

<hr />

## Table Of Contents

<br />

<hr />

## Mainnet Deployment

* Crowdsale contract [0xc2C7c5f64c2E3042852fb6Cbc3CAF9Ea1AfC018b](https://etherscan.io/address/0xc2C7c5f64c2E3042852fb6Cbc3CAF9Ea1AfC018b)
* BonusList [0x46c54e170D4Ce2F194C9C2B3Cc767A90b831CC06](https://etherscan.io/address/0x46c54e170D4Ce2F194C9C2B3Cc767A90b831CC06)

### Update Feb 25 2018

There was a [bug](https://github.com/bokkypoobah/BokkyPooBahsTokenTeleportationServiceSmartContract#history) in the original GZE token contract below:

* Token contract (old) [0x8C65e992297d5f092A756dEf24F4781a280198Ff](https://etherscan.io/address/0x8C65e992297d5f092A756dEf24F4781a280198Ff)
* Token explorer (old) [0x8C65e992297d5f092A756dEf24F4781a280198Ff](https://etherscan.io/token/0x8C65e992297d5f092A756dEf24F4781a280198Ff)

A new token contract based on [BTTS v1.10](https://github.com/bokkypoobah/BokkyPooBahsTokenTeleportationServiceSmartContract/blob/ec58bced28ed996cb8cb36bc5783472017fb3689/contracts/BTTSTokenFactory.sol)
was deployed on Feb 11 2018 with the balances from the old token contract transferred over, and this is now the GZE token contract:

* Token contract (new) [0x4AC00f287f36A6Aad655281fE1cA6798C9cb727b](https://etherscan.io/address/0x4AC00f287f36A6Aad655281fE1cA6798C9cb727b)
* Token explorer (new) [0x4AC00f287f36A6Aad655281fE1cA6798C9cb727b](https://etherscan.io/token/0x4AC00f287f36A6Aad655281fE1cA6798C9cb727b)

<br />

<hr />

## Requirements

* White list to run from now until Dec 5th
* Whitelisters receive 20% bonus
* ICO runs from Dec 10-21 . Start times are 11am EST. 11am EST is 22:00 AEDT and 16:00 GMT.

<br />

<hr />

## Deployment To Mainnet

* [x] Deploy BTTSLibrary - [0x655e9791](https://etherscan.io/tx/0x655e97912f8b1a0778897f46bc0e366f4029bbdb8ede92aa25ad14b71d8982b7) contract [0x9bB2eAe0BE24460a1f8292FB2C48c300F5622E64](https://etherscan.io/address/0x9bb2eae0be24460a1f8292fb2c48c300f5622e64)
* [x] Deploy BTTSTokenFactory - [0x7b179e55](https://etherscan.io/tx/0x7b179e5557202390c481c4523424054085a25d5f3908d38cedf4acba7fda6c88) contract [0x594dd662B580CA58b1186AF45551f34312e91e88](https://etherscan.io/address/0x594dd662b580ca58b1186af45551f34312e91e88)
* [x] Deploy BTTSToken from BTTSTokenFactory - [0x8931343d](https://etherscan.io/tx/0x8931343d0b2bc0791f5e7ce23f5ae538463233ac953b14bbb3ae847bfce75d75) contract [0x8C65e992297d5f092A756dEf24F4781a280198Ff](https://etherscan.io/address/0x8C65e992297d5f092A756dEf24F4781a280198Ff)
* [x] Deploy GazeCoinBonusList - [0xfbd4e0c4](https://etherscan.io/tx/0xfbd4e0c42787aea99db1c270cdcfdc25558a3217530a072c21c93cee24462a84) contract [0x46c54e170D4Ce2F194C9C2B3Cc767A90b831CC06](https://etherscan.io/address/0x46c54e170D4Ce2F194C9C2B3Cc767A90b831CC06)
* [x] Deploy GazeCoinCrowdsale - [0x52a088](https://etherscan.io/tx/0x52a088e7fea4ad19495268e8bad7e5092d2f715896f204c7edcf023c7967b0c0) contract [0xc2C7c5f64c2E3042852fb6Cbc3CAF9Ea1AfC018b](https://etherscan.io/address/0xc2C7c5f64c2E3042852fb6Cbc3CAF9Ea1AfC018b)
* [x] GazeCoinCrowdsale.setBTTSToken(BTTSToken) - 0x9cb242ce133edf08b6c61aa6c6c56479c49992ddbe9ae0ad6189903377d2a754
* [x] GazeCoinCrowdsale.setBonusList(GazeCoinBonusList) - 0xd7d74236b064517cf41939957287949876a8bb79e79621810fb5630d43b67c5c
* [x] BTTSToken.setMinter(GazeCoinCrowdsale) - 0xcbda5d4b53fa3af2368df8e3dda288794e4d4b6d1c4ae1ac1ad2c1595a009bbc
* [x] Check contract values
  * [x] usdPerEther 489.44
  * [x] gzePerEth 1398.40
  * [x] gzePerEth +15% 1608.16
  * [x] gzePerEth +20% 1678.08
  * [x] gzePerEth +35% 1887.84
  * [x] gzePerEth +50% 2097.60
* [x] Send test transaction of 0.01 ETH from the contract owner account before start of crowdsale
  * [x] Check tokens generated and ETH flow into multisig
* [x] GazeCoinCrowdsale.addPrecommitment(tokenOwner, ethAmount, bonusPercent)
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
