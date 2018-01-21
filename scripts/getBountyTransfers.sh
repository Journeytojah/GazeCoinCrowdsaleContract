#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //" > bountyTransfers.tsv

loadScript("token.js");

var fromBlock = 4818373;
var toBlock = 4818835;

function getAccounts() {
  var accounts = {};
  var transferEventsFilter = token.Transfer({}, {fromBlock: fromBlock, toBlock: toBlock});
  var transferEvents = transferEventsFilter.get();
  for (var i = 0; i < transferEvents.length; i++) {
    var transferEvent = transferEvents[i];
    console.log(JSON.stringify(transferEvent));
    if (transferEvent.args.from == "0xe796ad819e32846a7f2b28288a23f682eb4da9b4" || transferEvent.args.from == "0x000001f568875f378bf6d170b790967fe429c81a") {
      console.log("RESULT: " + transferEvent.args.from + "\t" + transferEvent.args.to + "\t" + transferEvent.args.tokens.shift(-18) + "\t" + transferEvent.transactionHash);
    }
  }
}

getAccounts();

EOF