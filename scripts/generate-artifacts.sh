#!/bin/bash

set -e

source ./scripts/env.sh

### Generate Channel Artifacts

mkdir -p channel-artifacts

# Generate Genesis Block for Orderer
configtxgen -profile OrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

# Generate Channel Configuration Transaction
configtxgen -profile ApplicationChannel -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

# Generate Anchor Peer Updates
configtxgen -profile ApplicationChannel -outputAnchorPeersUpdate ./channel-artifacts/TalentOrgAnchor.tx -channelID $CHANNEL_NAME -asOrg TalentOrg
configtxgen -profile ApplicationChannel -outputAnchorPeersUpdate ./channel-artifacts/UniversityOrgAnchor.tx -channelID $CHANNEL_NAME -asOrg UniversityOrg
configtxgen -profile ApplicationChannel -outputAnchorPeersUpdate ./channel-artifacts/CompanyOrgAnchor.tx -channelID $CHANNEL_NAME -asOrg CompanyOrg
