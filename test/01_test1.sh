#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

TOKENFACTORYSOL=`grep ^TOKENFACTORYSOL= settings.txt | sed "s/^.*=//"`
TOKENFACTORYJS=`grep ^TOKENFACTORYJS= settings.txt | sed "s/^.*=//"`
CROWDSALESOL=`grep ^CROWDSALESOL= settings.txt | sed "s/^.*=//"`
CROWDSALEJS=`grep ^CROWDSALEJS= settings.txt | sed "s/^.*=//"`
BONUSLISTSOL=`grep ^BONUSLISTSOL= settings.txt | sed "s/^.*=//"`
BONUSLISTJS=`grep ^BONUSLISTJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`
JSONSUMMARY=`grep ^JSONSUMMARY= settings.txt | sed "s/^.*=//"`
JSONEVENTS=`grep ^JSONEVENTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

START_DATE=`echo "$CURRENTTIME+60*2+30" | bc`
START_DATE_S=`date -r $START_DATE -u`
END_DATE=`echo "$CURRENTTIME+60*4" | bc`
END_DATE_S=`date -r $END_DATE -u`

printf "MODE               = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT    = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD           = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR          = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "TOKENFACTORYSOL    = '$TOKENFACTORYSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENFACTORYJS     = '$TOKENFACTORYJS'\n" | tee -a $TEST1OUTPUT
printf "CROWDSALESOL       = '$CROWDSALESOL'\n" | tee -a $TEST1OUTPUT
printf "CROWDSALEJS        = '$CROWDSALEJS'\n" | tee -a $TEST1OUTPUT
printf "BONUSLISTSOL       = '$BONUSLISTSOL'\n" | tee -a $TEST1OUTPUT
printf "BONUSLISTJS        = '$BONUSLISTJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS          = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "JSONSUMMARY        = '$JSONSUMMARY'\n" | tee -a $TEST1OUTPUT
printf "JSONEVENTS         = '$JSONEVENTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/$TOKENFACTORYSOL .`
`cp $SOURCEDIR/$CROWDSALESOL .`
`cp $SOURCEDIR/$BONUSLISTSOL .`

# --- Modify parameters ---
`perl -pi -e "s/START_DATE \= 1512921600;.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
`perl -pi -e "s/endDate \= 1513872000;.*$/endDate \= $END_DATE; \/\/ $END_DATE_S/" $CROWDSALESOL`

DIFFS1=`diff $SOURCEDIR/$TOKENFACTORYSOL $TOKENFACTORYSOL`
echo "--- Differences $SOURCEDIR/$TOKENFACTORYSOL $TOKENFACTORYSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL`
echo "--- Differences $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$BONUSLISTSOL $BONUSLISTSOL`
echo "--- Differences $SOURCEDIR/$BONUSLISTSOL $BONUSLISTSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.18 --version | tee -a $TEST1OUTPUT

echo "var tokenFactoryOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $TOKENFACTORYSOL`;" > $TOKENFACTORYJS
echo "var crowdsaleOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $CROWDSALESOL`;" > $CROWDSALEJS
echo "var bonusListOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $BONUSLISTSOL`;" > $BONUSLISTJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$TOKENFACTORYJS");
loadScript("$CROWDSALEJS");
loadScript("$BONUSLISTJS");
loadScript("functions.js");

var tokenFactoryLibBTTSAbi = JSON.parse(tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSLib"].abi);
var tokenFactoryLibBTTSBin = "0x" + tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSLib"].bin;
var tokenFactoryAbi = JSON.parse(tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSTokenFactory"].abi);
var tokenFactoryBin = "0x" + tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSTokenFactory"].bin;
var tokenAbi = JSON.parse(tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSToken"].abi);
var crowdsaleAbi = JSON.parse(crowdsaleOutput.contracts["$CROWDSALESOL:GazeCoinCrowdsale"].abi);
var crowdsaleBin = "0x" + crowdsaleOutput.contracts["$CROWDSALESOL:GazeCoinCrowdsale"].bin;
var bonusListAbi = JSON.parse(bonusListOutput.contracts["$BONUSLISTSOL:GazeCoinBonusList"].abi);
var bonusListBin = "0x" + bonusListOutput.contracts["$BONUSLISTSOL:GazeCoinBonusList"].bin;

// console.log("DATA: tokenFactoryLibBTTSAbi=" + JSON.stringify(tokenFactoryLibBTTSAbi));
// console.log("DATA: tokenFactoryLibBTTSBin=" + JSON.stringify(tokenFactoryLibBTTSBin));
// console.log("DATA: tokenFactoryAbi=" + JSON.stringify(tokenFactoryAbi));
// console.log("DATA: tokenFactoryBin=" + JSON.stringify(tokenFactoryBin));
// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: crowdsaleAbi=" + JSON.stringify(crowdsaleAbi));
// console.log("DATA: crowdsaleBin=" + JSON.stringify(crowdsaleBin));
// console.log("DATA: bonusListAbi=" + JSON.stringify(bonusListAbi));
// console.log("DATA: bonusListBin=" + JSON.stringify(bonusListBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployLibBTTSMessage = "Deploy BTTS Library";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployLibBTTSMessage);
var tokenFactoryLibBTTSContract = web3.eth.contract(tokenFactoryLibBTTSAbi);
// console.log(JSON.stringify(tokenFactoryLibBTTSContract));
var tokenFactoryLibBTTSTx = null;
var tokenFactoryLibBTTSAddress = null;
var tokenFactoryLibBTTS = tokenFactoryLibBTTSContract.new({from: contractOwnerAccount, data: tokenFactoryLibBTTSBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenFactoryLibBTTSTx = contract.transactionHash;
      } else {
        tokenFactoryLibBTTSAddress = contract.address;
        addAccount(tokenFactoryLibBTTSAddress, "BTTS Library");
        console.log("DATA: tokenFactoryLibBTTSAddress=" + tokenFactoryLibBTTSAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenFactoryLibBTTSTx, deployLibBTTSMessage);
printTxData("tokenFactoryLibBTTSTx", tokenFactoryLibBTTSTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployTokenFactoryMessage = "Deploy BTTSTokenFactory";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployTokenFactoryMessage);
// console.log("RESULT: tokenFactoryBin='" + tokenFactoryBin + "'");
var newTokenFactoryBin = tokenFactoryBin.replace(/__BTTSTokenFactory\.sol\:BTTSLib__________/g, tokenFactoryLibBTTSAddress.substring(2, 42));
// console.log("RESULT: newTokenFactoryBin='" + newTokenFactoryBin + "'");
var tokenFactoryContract = web3.eth.contract(tokenFactoryAbi);
// console.log(JSON.stringify(tokenFactoryAbi));
// console.log(tokenFactoryBin);
var tokenFactoryTx = null;
var tokenFactoryAddress = null;
var tokenFactory = tokenFactoryContract.new({from: contractOwnerAccount, data: newTokenFactoryBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenFactoryTx = contract.transactionHash;
      } else {
        tokenFactoryAddress = contract.address;
        addAccount(tokenFactoryAddress, "BTTSTokenFactory");
        addTokenFactoryContractAddressAndAbi(tokenFactoryAddress, tokenFactoryAbi);
        console.log("DATA: tokenFactoryAddress=" + tokenFactoryAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenFactoryTx, deployTokenFactoryMessage);
printTxData("tokenFactoryTx", tokenFactoryTx);
printTokenFactoryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Token Contract";
var symbol = "GZE";
var name = "GazeCoin";
var decimals = 18;
var initialSupply = 0;
var mintable = true;
var transferable = false;
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var deployTokenTx = tokenFactory.deployBTTSTokenContract(symbol, name, decimals, initialSupply, mintable, transferable, {from: contractOwnerAccount, gas: 4000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var bttsTokens = getBTTSFactoryTokenListing();
console.log("RESULT: bttsTokens=#" + bttsTokens.length + " " + JSON.stringify(bttsTokens));
// Can check, but the rest will not work anyway - if (bttsTokens.length == 1)
var tokenAddress = bttsTokens[0];
var token = web3.eth.contract(tokenAbi).at(tokenAddress);
// console.log("RESULT: token=" + JSON.stringify(token));
addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
printBalances();
printTxData("deployTokenTx", deployTokenTx);
printTokenFactoryContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var crowdsaleMessage = "Deploy GazeCoin Crowdsale Contract";
var bonusListMessage = "Deploy Bonus List Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + crowdsaleMessage);
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
// console.log(JSON.stringify(crowdsaleContract));
var crowdsaleTx = null;
var crowdsaleAddress = null;
var crowdsale = crowdsaleContract.new({from: contractOwnerAccount, data: crowdsaleBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        crowdsaleTx = contract.transactionHash;
      } else {
        crowdsaleAddress = contract.address;
        addAccount(crowdsaleAddress, "GazeCoin Crowdsale");
        addCrowdsaleContractAddressAndAbi(crowdsaleAddress, crowdsaleAbi);
        console.log("DATA: crowdsaleAddress=" + crowdsaleAddress);
      }
    }
  }
);
console.log("RESULT: " + bonusListMessage);
var bonusListContract = web3.eth.contract(bonusListAbi);
// console.log(JSON.stringify(bonusListContract));
var bonusListTx = null;
var bonusListAddress = null;
var bonusList = bonusListContract.new({from: contractOwnerAccount, data: bonusListBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        bonusListTx = contract.transactionHash;
      } else {
        bonusListAddress = contract.address;
        addAccount(bonusListAddress, "Bonus List");
        addBonusListContractAddressAndAbi(bonusListAddress, bonusListAbi);
        console.log("DATA: bonusListAddress=" + bonusListAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(crowdsaleTx, crowdsaleMessage);
failIfTxStatusError(bonusListTx, bonusListMessage);
printTxData("crowdsaleAddress=" + crowdsaleAddress, crowdsaleTx);
printTxData("bonusListAddress=" + bonusListAddress, bonusListTx);
printCrowdsaleContractDetails();
printBonusListContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setup_Message = "Setup";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setup_Message);
var setup_1Tx = crowdsale.setBTTSToken(tokenAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_2Tx = crowdsale.setBonusList(bonusListAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_3Tx = crowdsale.setEndDate($END_DATE, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_4Tx = token.setMinter(crowdsaleAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_5Tx = bonusList.add([account3], 1, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_6Tx = bonusList.add([account4], 2, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_7Tx = bonusList.add([account5], 3, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setup_1Tx, setup_Message + " - crowdsale.setBTTSToken(tokenAddress)");
failIfTxStatusError(setup_2Tx, setup_Message + " - crowdsale.setBonusList(bonusListAddress)");
failIfTxStatusError(setup_3Tx, setup_Message + " - crowdsale.setEndDate($END_DATE)");
failIfTxStatusError(setup_4Tx, setup_Message + " - token.setMinter(crowdsaleAddress)");
failIfTxStatusError(setup_5Tx, setup_Message + " - bonusList.add([account3], 1)");
failIfTxStatusError(setup_6Tx, setup_Message + " - bonusList.add([account4], 2)");
failIfTxStatusError(setup_7Tx, setup_Message + " - bonusList.add([account5], 3)");
printTxData("setup_1Tx", setup_1Tx);
printTxData("setup_2Tx", setup_2Tx);
printTxData("setup_3Tx", setup_3Tx);
printTxData("setup_4Tx", setup_4Tx);
printTxData("setup_5Tx", setup_5Tx);
printTxData("setup_6Tx", setup_6Tx);
printTxData("setup_7Tx", setup_7Tx);
printCrowdsaleContractDetails();
printBonusListContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var addPrecommitment_Message = "Add Precommitment";
// -----------------------------------------------------------------------------
console.log("RESULT: " + addPrecommitment_Message);
var addPrecommitment_1Tx = crowdsale.addPrecommitment(account7, web3.toWei(1000, "ether"), 35, {from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(addPrecommitment_1Tx, addPrecommitment_Message + " - ac7 1,000 ETH with 35% bonus");
printTxData("addPrecommitment_1Tx", addPrecommitment_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution0Message = "Send Contribution #0 - Before Crowdsale Start";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution0Message);
var sendContribution0_1Tx = eth.sendTransaction({from: contractOwnerAccount, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.01", "ether")});
var sendContribution0_2Tx = eth.sendTransaction({from: contractOwnerAccount, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.02", "ether")});
var sendContribution0_3Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.01", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution0_1Tx, sendContribution0Message + " - owner 0.01 ETH - Owner Test Transaction");
passIfTxStatusError(sendContribution0_2Tx, sendContribution0Message + " - owner 0.02 ETH - Expecting failure - not a test transaction");
passIfTxStatusError(sendContribution0_3Tx, sendContribution0Message + " - ac3 0.01 ETH - Expecting failure");
printTxData("sendContribution0_1Tx", sendContribution0_1Tx);
printTxData("sendContribution0_2Tx", sendContribution0_2Tx);
printTxData("sendContribution0_3Tx", sendContribution0_3Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("START_DATE", crowdsale.START_DATE(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("10", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("10", "ether")});
var sendContribution1_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("10", "ether")});
var sendContribution1_4Tx = eth.sendTransaction({from: account6, to: crowdsaleAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 10 ETH - Bonus Tier 1 50%");
failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac4 10 ETH - Bonus Tier 2 20%");
failIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " - ac5 10 ETH - Bonus Tier 3 15%");
failIfTxStatusError(sendContribution1_4Tx, sendContribution1Message + " - ac6 10 ETH - No Bonus");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTxData("sendContribution1_3Tx", sendContribution1_3Tx);
printTxData("sendContribution1_4Tx", sendContribution1_4Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("90", "ether")});
var sendContribution2_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("90", "ether")});
var sendContribution2_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("90", "ether")});
var sendContribution2_4Tx = eth.sendTransaction({from: account6, to: crowdsaleAddress, gas: 400000, value: web3.toWei("90", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac3 90 ETH - Bonus Tier 1 50%");
failIfTxStatusError(sendContribution2_2Tx, sendContribution2Message + " - ac4 90 ETH - Bonus Tier 2 20%");
failIfTxStatusError(sendContribution2_3Tx, sendContribution2Message + " - ac5 90 ETH - Bonus Tier 3 15%");
failIfTxStatusError(sendContribution2_4Tx, sendContribution2Message + " - ac6 90 ETH - No Bonus");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTxData("sendContribution2_2Tx", sendContribution2_2Tx);
printTxData("sendContribution2_3Tx", sendContribution2_3Tx);
printTxData("sendContribution2_4Tx", sendContribution2_4Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution3Message = "Send Contribution #3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution3Message);
var sendContribution3_1Tx = eth.sendTransaction({from: account8, to: crowdsaleAddress, gas: 400000, value: web3.toWei("50000", "ether")});
while (txpool.status.pending > 0) {
}
var sendContribution3_2Tx = eth.sendTransaction({from: account9, to: crowdsaleAddress, gas: 400000, value: web3.toWei("30000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac8 50,000 ETH");
failIfTxStatusError(sendContribution3_2Tx, sendContribution3Message + " - ac9 30,000 ETH");
printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
printTxData("sendContribution3_2Tx", sendContribution3_2Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var addPrecommitmentAdjustment_Message = "Add Precommitment Adjustment";
// -----------------------------------------------------------------------------
console.log("RESULT: " + addPrecommitmentAdjustment_Message);
var addPrecommitmentAdjustment_1Tx = crowdsale.addPrecommitmentAdjustment(account7, new BigNumber("111").shift(18), {from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(addPrecommitmentAdjustment_1Tx, addPrecommitmentAdjustment_Message + " - ac7 + 111 GZE");
printTxData("addPrecommitmentAdjustment_1Tx", addPrecommitmentAdjustment_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise_Message = "Finalise Crowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finalise_Message);
var finalise_1Tx = crowdsale.finalise({from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(finalise_1Tx, finalise_Message);
printTxData("finalise_1Tx", finalise_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
