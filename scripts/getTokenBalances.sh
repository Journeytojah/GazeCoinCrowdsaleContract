#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //" > tokenBalances.tsv

loadScript("token.js");

var fromBlock = 4708077;
var toBlock = "latest";

function getAccounts() {
  var accounts = {};
  var transferEventsFilter = token.Transfer({}, {fromBlock: fromBlock, toBlock: toBlock});
  var transferEvents = transferEventsFilter.get();
  for (var i = 0; i < transferEvents.length; i++) {
    var transferEvent = transferEvents[i];
    console.log(JSON.stringify(transferEvent));
    accounts[transferEvent.args.from] = 1;
    accounts[transferEvent.args.to] = 1;
  }
  return Object.keys(accounts).sort();
}

function getBalances(accounts) {
    var totalBalance = new BigNumber(0);
    for (var i = 0; i < accounts.length; i++) {
        var account = accounts[i];
        var amount = token.balanceOf(account, toBlock);
        totalBalance = totalBalance.add(amount);
        console.log("RESULT: " + account + "\t" + amount.shift(-18));
    }
    console.log("RESULT: Total\t" + totalBalance.shift(-18));
}

var accounts = getAccounts();
getBalances(accounts);

EOF