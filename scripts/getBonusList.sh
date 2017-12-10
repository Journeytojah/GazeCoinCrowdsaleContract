#!/bin/sh

geth attach << EOF | grep "RESULT:" | sed "s/RESULT: //" > bonusListOutput.txt
loadScript("bonusList.js");

var fromBlock = 4708855;
var toBlock = "latest";
var contract = eth.contract(bonusListAbi).at(bonusListAddress);

var addressListedEvents = contract.AddressListed({}, { fromBlock: fromBlock, toBlock: toBlock });
var i = 0;
addressListedEvents.watch(function (error, result) {
  console.log("RESULT: BonusList," + i++ + "," + result.blockNumber + "," + result.args.addr + "," + result.args.tier);
});
addressListedEvents.stopWatching();

EOF
