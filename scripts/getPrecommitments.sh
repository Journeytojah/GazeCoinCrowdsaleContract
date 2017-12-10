#!/bin/sh

geth attach << EOF | grep "RESULT:" | sed "s/RESULT: //" > precommitmentOutput.txt
loadScript("crowdsale.js");

var fromBlock = 4708717;
var toBlock = 4708733;
var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);

var contributedEvents = contract.Contributed({}, { fromBlock: fromBlock, toBlock: toBlock });
var i = 0;
contributedEvents.watch(function (error, result) {
  console.log("RESULT: Contributed " + i++ + " #" + result.blockNumber + " addr=" + result.args.addr + 
    " ethAmount=" + result.args.ethAmount + " " + result.args.ethAmount.shift(-18) + " ETH" +
    " ethRefund=" + result.args.ethRefund + " " + result.args.ethRefund.shift(-18) + " ETH" +
    " accountEthAmount=" + result.args.accountEthAmount + " " + result.args.accountEthAmount.shift(-18) + " ETH" +
    " usdAmount=" + result.args.usdAmount + " USD" +
    " gzeAmount=" + result.args.gzeAmount + " " + result.args.gzeAmount.shift(-18) + " GZE" +
    " contributedEth=" + result.args.contributedEth + " " + result.args.contributedEth.shift(-18) + " ETH" +
    " contributedUsd=" + result.args.contributedUsd + " USD" +
    " generatedGze=" + result.args.generatedGze + " " + result.args.generatedGze.shift(-18) + " GZE" +
    " lockAccount=" + result.args.lockAccount);
});
contributedEvents.stopWatching();

EOF
