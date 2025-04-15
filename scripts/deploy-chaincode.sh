#!/bin/bash

set -e

source ./scripts/env.sh

cd talent-chaincode
npm install
cd ..

export FABRIC_CFG_PATH=$PWD/organizations/peerOrganizations/talentorg/peers/peer0.talentorg

peer lifecycle chaincode package talent-chaincode.tar.gz --path ./talent-chaincode --lang node --label talentcc_1

function get_msp_id() {
  case "$1" in
    talentorg) echo "TalentOrg" ;;
    universityorg) echo "UniversityOrg" ;;
    companyorg) echo "CompanyOrg" ;;
    ordererorg) echo "OrdererOrg" ;;
    *) echo "UnknownOrg" && exit 1 ;;
  esac
}

function install_and_approve {
  local ORG=$1
  local PORT=$2

  export CORE_PEER_LOCALMSPID=$(get_msp_id $ORG)
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/$ORG/msp
  export CORE_PEER_ADDRESS=127.0.0.1:$PORT
  export FABRIC_CFG_PATH=${PWD}/organizations/peerOrganizations/$ORG/peers/peer0.$ORG
  export CORE_PEER_TLS_ENABLED=false

  peer lifecycle chaincode install talent-chaincode.tar.gz

  PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | \
    grep "Label: talentcc_1" | \
    sed -n 's/^Package ID: //p' | \
    cut -d',' -f1)

  echo "Detected Package ID: $PACKAGE_ID"

  peer lifecycle chaincode approveformyorg -o 127.0.0.1:11500 --channelID $CHANNEL_NAME --name talentcc --version 1.0 --package-id $PACKAGE_ID --sequence 1
}

install_and_approve "talentorg" 45540
install_and_approve "universityorg" 20510
install_and_approve "companyorg" 30510

peer lifecycle chaincode commit -o 127.0.0.1:11500 --channelID $CHANNEL_NAME --name talentcc --version 1.0 --sequence 1 \
  --peerAddresses 127.0.0.1:45540 \
  --peerAddresses 127.0.0.1:20510 \
  --peerAddresses 127.0.0.1:30510
