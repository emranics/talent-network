#!/bin/bash

set -e

source ./scripts/env.sh

### Create and Join Channel and Update Anchor Peers

function get_msp_id() {
  case "$1" in
    talentorg) echo "TalentOrg" ;;
    universityorg) echo "UniversityOrg" ;;
    companyorg) echo "CompanyOrg" ;;
    ordererorg) echo "OrdererOrg" ;;
    *) echo "UnknownOrg" && exit 1 ;;
  esac
}

function join_channel {
  local ORG=$1
  local PORT=$2
  local MSP=$PWD/organizations/peerOrganizations/$ORG/msp
  local PEER_DIR=$PWD/organizations/peerOrganizations/$ORG/peers/peer0.$ORG

  export CORE_PEER_LOCALMSPID=$(get_msp_id $ORG)
  export CORE_PEER_MSPCONFIGPATH=$MSP
  export CORE_PEER_ADDRESS=127.0.0.1:$PORT
  export FABRIC_CFG_PATH=$PEER_DIR

  echo "Joining as $CORE_PEER_LOCALMSPID ($CORE_PEER_ADDRESS)"

  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
  peer channel update -o 127.0.0.1:11500 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}Anchor.tx
}

# Create the Channel (Run as TalentOrg)
export CORE_PEER_LOCALMSPID=TalentOrg
export CORE_PEER_MSPCONFIGPATH=$PWD/organizations/peerOrganizations/talentorg/msp
export CORE_PEER_ADDRESS=127.0.0.1:45540
export FABRIC_CFG_PATH=$PWD/organizations/peerOrganizations/talentorg/peers/peer0.talentorg

peer channel create -o 127.0.0.1:11500 -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx --outputBlock ./channel-artifacts/$CHANNEL_NAME.block

join_channel "talentorg" 45540
join_channel "universityorg" 20510
join_channel "companyorg" 30510
