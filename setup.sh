
# Remove macOS quarantine restrictions
sudo xattr -rd com.apple.quarantine .

# Double-check permissions
sudo chmod +x ./scripts/*.sh


## Run API #######################
cd talent-api
npm install
npm start
##################################
##################################
##################################




## Commands ##################################################################################

export PATH=$PWD/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/config
export CHANNEL_NAME=talentchannel
export CORE_PEER_LOCALMSPID=TalentOrg
export CORE_PEER_MSPCONFIGPATH=$PWD/organizations/peerOrganizations/talentorg/msp
export CORE_PEER_ADDRESS=127.0.0.1:45540
export FABRIC_CFG_PATH=$PWD/organizations/peerOrganizations/talentorg/peers/peer0.talentorg
export CORE_PEER_TLS_ENABLED=false
export CC_NAME=talentcc
export CHANNEL_NAME=talentchannel
export ORDERER=127.0.0.1:11500


#RegisterTalent
peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"RegisterTalent","Args":["talent001","John Doe","john@example.com"]}' \
  --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


#GetTalentInfo
peer chaincode query -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"GetTalentInfo","Args":["talent001"]}' \
  --peerAddresses 127.0.0.1:45540


#ShareProfile
peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"ShareProfile","Args":["talent001","companyABC"]}' \
  --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


#ListAllTalents
peer chaincode query -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"ListAllTalents","Args":[]}' \
  --peerAddresses 127.0.0.1:45540


#AddCredential
peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"AddCredential","Args":["talent001","cred001","Degree","University XYZ","Bachelor of Science"]}' \
  --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


#VerifyCredential
peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"VerifyCredential","Args":["talent001","cred001","University XYZ"]}' \
  --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


#RevokeCredential
peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"RevokeCredential","Args":["talent001","cred001","University XYZ"]}' \
  --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


#GetCredentialByID
peer chaincode query -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"GetCredentialByID","Args":["talent001","cred001"]}' \
  --peerAddresses 127.0.0.1:45540


#ViewSharedProfile
peer chaincode query -o $ORDERER -C $CHANNEL_NAME -n $CC_NAME \
  -c '{"function":"ViewSharedProfile","Args":["talent001","companyABC"]}' \
  --peerAddresses 127.0.0.1:45540

###############################################################################################
###############################################################################################
###############################################################################################






# Check Channel Info
peer channel getinfo -c $CHANNEL_NAME


#peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name talentcc --version 1.0 --sequence 1 --output json


#peer lifecycle chaincode queryinstalled
#peer lifecycle chaincode querycommitted --channelID talentchannel




### for read-only actions --------> peer chaincode query


##############################
## for development environmend:

peer chaincode invoke -o 127.0.0.1:11500 -C $CHANNEL_NAME -n talentcc -c '{"function":"RegisterTalent","Args":["talent001","John Doe","john@example.com"]}' --peerAddresses 127.0.0.1:45540


##############################
## for production environmend:

peer chaincode invoke -o 127.0.0.1:11500 -C $CHANNEL_NAME -n talentcc -c '{"function":"RegisterTalent","Args":["talent001","John Doe","john@example.com"]}' --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


peer chaincode invoke -o 127.0.0.1:11500 -C $CHANNEL_NAME -n talentcc -c '{"function":"AddCredential","Args":["talent001","cred001","Degree","University XYZ","Bachelor of Science"]}' --peerAddresses 127.0.0.1:45540 --peerAddresses 127.0.0.1:20510 --peerAddresses 127.0.0.1:30510


peer chaincode query -o 127.0.0.1:11500 -C $CHANNEL_NAME -n talentcc -c '{"function":"GetTalentInfo","Args":["talent001"]}' --peerAddresses 127.0.0.1:45540

