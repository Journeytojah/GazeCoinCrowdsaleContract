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

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

START_DATE=`echo "$CURRENTTIME+45" | bc`
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
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS          = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/$TOKENFACTORYSOL .`
`cp $SOURCEDIR/$CROWDSALESOL .`

# --- Modify parameters ---
`perl -pi -e "s/START_DATE \= 1512921600;.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
`perl -pi -e "s/END_DATE \= 1513872000;.*$/END_DATE \= $END_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`

DIFFS1=`diff $SOURCEDIR/$TOKENFACTORYSOL $TOKENFACTORYSOL`
echo "--- Differences $SOURCEDIR/$TOKENFACTORYSOL $TOKENFACTORYSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL`
echo "--- Differences $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.18 --version | tee -a $TEST1OUTPUT

echo "var tokenFactoryOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $TOKENFACTORYSOL`;" > $TOKENFACTORYJS
echo "var crowdsaleOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $CROWDSALESOL`;" > $CROWDSALEJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$TOKENFACTORYJS");
loadScript("$CROWDSALEJS");
loadScript("functions.js");

var tokenFactoryLibBTTSAbi = JSON.parse(tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSLib"].abi);
var tokenFactoryLibBTTSBin = "0x" + tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSLib"].bin;
var tokenFactoryAbi = JSON.parse(tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSTokenFactory"].abi);
var tokenFactoryBin = "0x" + tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSTokenFactory"].bin;
var tokenAbi = JSON.parse(tokenFactoryOutput.contracts["$TOKENFACTORYSOL:BTTSToken"].abi);
var crowdsaleAbi = JSON.parse(crowdsaleOutput.contracts["$CROWDSALESOL:GazeCoinCrowdsale"].abi);
var crowdsaleBin = "0x" + crowdsaleOutput.contracts["$CROWDSALESOL:GazeCoinCrowdsale"].bin;

// console.log("DATA: tokenFactoryLibBTTSAbi=" + JSON.stringify(tokenFactoryLibBTTSAbi));
// console.log("DATA: tokenFactoryLibBTTSBin=" + JSON.stringify(tokenFactoryLibBTTSBin));
// console.log("DATA: tokenFactoryAbi=" + JSON.stringify(tokenFactoryAbi));
// console.log("DATA: tokenFactoryBin=" + JSON.stringify(tokenFactoryBin));
// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: crowdsaleAbi=" + JSON.stringify(crowdsaleAbi));
// console.log("DATA: crowdsaleBin=" + JSON.stringify(crowdsaleBin));

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
// -----------------------------------------------------------------------------
console.log("RESULT: " + crowdsaleMessage);
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
// console.log(JSON.stringify(crowdsaleContract));
var crowdsaleTx = null;
var crowdsaleAddress = null;
var crowdsale = crowdsaleContract.new(wallet, {from: contractOwnerAccount, data: crowdsaleBin, gas: 6000000, gasPrice: defaultGasPrice},
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
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(crowdsaleTx, crowdsaleMessage);
printTxData("crowdsaleAddress=" + crowdsaleAddress, crowdsaleTx);
printCrowdsaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setCrowdsaleToken_Message = "Set Crowdsale Token To GZE";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setCrowdsaleToken_Message);
var setCrowdsaleToken_1Tx = crowdsale.setBTTSToken(tokenAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setCrowdsaleToken_2Tx = token.setMinter(crowdsaleAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setCrowdsaleToken_1Tx, setCrowdsaleToken_Message + " - crowdsale.setBTTSToken(tokenAddress)");
failIfTxStatusError(setCrowdsaleToken_2Tx, setCrowdsaleToken_Message + " - token.setMinter(crowdsaleAddress)");
printTxData("setCrowdsaleToken_1Tx", setCrowdsaleToken_1Tx);
printTxData("setCrowdsaleToken_2Tx", setCrowdsaleToken_2Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("START_DATE", crowdsale.START_DATE(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("4000", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account6, to: crowdsaleAddress, gas: 400000, value: web3.toWei("3000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 4,000 ETH");
failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac4 3,000 ETH");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("50000", "ether")});
while (txpool.status.pending > 0) {
}
var sendContribution2_2Tx = eth.sendTransaction({from: account7, to: crowdsaleAddress, gas: 400000, value: web3.toWei("30000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac4 50,000 ETH");
failIfTxStatusError(sendContribution2_2Tx, sendContribution2Message + " - ac7 30,000 ETH");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTxData("sendContribution2_2Tx", sendContribution2_2Tx);
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


exit;

// -----------------------------------------------------------------------------
var whitelistAccounts_Message = "Whitelist Accounts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistAccounts_Message);
var whitelistAccounts_1Tx = whitelist.multiAdd([account3, account5], [1, 1], {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(whitelistAccounts_1Tx, whitelistAccounts_Message + " - multiAdd([account3, account4, account5], [1, 1, 1])");
printTxData("whitelistAccounts_1Tx", whitelistAccounts_1Tx);
printWhitelistContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var picopsCertifierMessage = "Deploy Test PICOPS Certifier Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + picopsCertifierMessage);
var picopsCertifierContract = web3.eth.contract(picopsCertifierAbi);
// console.log(JSON.stringify(picopsCertifierContract));
var picopsCertifierTx = null;
var picopsCertifierAddress = null;
var picopsCertifier = picopsCertifierContract.new({from: contractOwnerAccount, data: picopsCertifierBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        picopsCertifierTx = contract.transactionHash;
      } else {
        picopsCertifierAddress = contract.address;
        addAccount(picopsCertifierAddress, "Test PICOPS Certifier");
        console.log("DATA: picopsCertifierAddress=" + picopsCertifierAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(picopsCertifierTx, picopsCertifierMessage);
printTxData("picopsCertifierAddress=" + picopsCertifierAddress, picopsCertifierTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new(wallet, {from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, tokenMessage);
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setTokenParameters_Message = "Set Token Contract Parameters";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setTokenParameters_Message);
var setTokenParameters_1Tx = token.setEthMinContribution(web3.toWei(10, "ether"), {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_2Tx = token.setUsdCap(2200000, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_3Tx = token.setUsdPerKEther(444444, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_4Tx = token.setWhitelist(whitelistAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_5Tx = token.setPICOPSCertifier(picopsCertifierAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setTokenParameters_1Tx, setTokenParameters_Message + " - token.setEthMinContribution(10 ETH)");
failIfTxStatusError(setTokenParameters_2Tx, setTokenParameters_Message + " - token.setUsdCap(2,200,000)");
failIfTxStatusError(setTokenParameters_3Tx, setTokenParameters_Message + " - token.setUsdPerKEther(444,444)");
failIfTxStatusError(setTokenParameters_4Tx, setTokenParameters_Message + " - token.setWhitelist(whitelistAddress)");
failIfTxStatusError(setTokenParameters_5Tx, setTokenParameters_Message + " - token.setPICOPSCertifier(picopsCertifierAddress)");
printTxData("setTokenParameters_1Tx", setTokenParameters_1Tx);
printTxData("setTokenParameters_2Tx", setTokenParameters_2Tx);
printTxData("setTokenParameters_3Tx", setTokenParameters_3Tx);
printTxData("setTokenParameters_4Tx", setTokenParameters_4Tx);
printTxData("setTokenParameters_5Tx", setTokenParameters_5Tx);
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("START_DATE", token.START_DATE(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("4000", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account6, to: tokenAddress, gas: 400000, value: web3.toWei("3000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 4,000 ETH");
passIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac6 3,000 ETH - Expecting failure as not whitelisted");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("4000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac4 4,000 ETH - Only partial amount accepted");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution3Message = "Send Contribution #3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution3Message);
var sendContribution3_1Tx = eth.sendTransaction({from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("4000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
passIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac5 4,000 ETH - Expecting failure");
printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var moveToken1_Message = "Move Tokens After Presale - To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken1_Message);
var moveToken1_1Tx = token.transfer(redemptionWallet, "1000000", {from: account3, gas: 100000});
var moveToken1_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken1_3Tx = token.transferFrom(account4, redemptionWallet, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken1_1Tx", moveToken1_1Tx);
printTxData("moveToken1_2Tx", moveToken1_2Tx);
printTxData("moveToken1_3Tx", moveToken1_3Tx);
failIfTxStatusError(moveToken1_1Tx, moveToken1_Message + " - transfer 1 token ac3 -> redemptionWallet. CHECK for movement");
failIfTxStatusError(moveToken1_2Tx, moveToken1_Message + " - approve 30 tokens ac4 -> ac6");
failIfTxStatusError(moveToken1_3Tx, moveToken1_Message + " - transferFrom 30 tokens ac4 -> redemptionWallet by ac6. CHECK for movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveToken2_Message = "Move Tokens After Presale - Not To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken2_Message);
var moveToken2_1Tx = token.transfer(account5, "1000000", {from: account3, gas: 100000});
var moveToken2_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken2_3Tx = token.transferFrom(account4, account7, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken2_1Tx", moveToken2_1Tx);
printTxData("moveToken2_2Tx", moveToken2_2Tx);
printTxData("moveToken2_3Tx", moveToken2_3Tx);
passIfTxStatusError(moveToken2_1Tx, moveToken2_Message + " - transfer 1 token ac3 -> ac5. Expecting failure");
failIfTxStatusError(moveToken2_2Tx, moveToken2_Message + " - approve 30 tokens ac4 -> ac6");
passIfTxStatusError(moveToken2_3Tx, moveToken2_Message + " - transferFrom 30 tokens ac4 -> ac7 by ac6. Expecting failure");
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
