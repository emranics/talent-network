#!/bin/bash

set -e

source ./scripts/env.sh

### Register and Enroll Identities

function enroll_and_register_admin {
  local ORG_NAME=$1
  local PORT=$2
  local CA_DIR=$PWD/organizations/fabric-ca/$ORG_NAME
  local MSP_DEST=$PWD/organizations/peerOrganizations/$ORG_NAME
  if [[ "$ORG_NAME" == "ordererorg" ]]; then
    MSP_DEST=$PWD/organizations/ordererOrganizations/orderer.example.com
  fi

  export FABRIC_CA_CLIENT_HOME=$CA_DIR
  export MSP_DEST_PATH=$MSP_DEST
  export FABRIC_CA_CLIENT_TLS_CERTFILES=""

  fabric-ca-client enroll -u http://admin:adminpw@localhost:$PORT --tls.certfiles ""
  fabric-ca-client register --id.name ${ORG_NAME}-admin --id.secret ${ORG_NAME}adminpw --id.type admin --tls.certfiles ""
  fabric-ca-client enroll -u http://${ORG_NAME}-admin:${ORG_NAME}adminpw@localhost:$PORT --tls.certfiles "" -M $MSP_DEST/users/Admin@${ORG_NAME}/msp

  mkdir -p $MSP_DEST/users/Admin@${ORG_NAME}/msp/admincerts
  cp $MSP_DEST/users/Admin@${ORG_NAME}/msp/signcerts/cert.pem $MSP_DEST/users/Admin@${ORG_NAME}/msp/admincerts/

  mkdir -p $MSP_DEST/msp
  cp -r $CA_DIR/msp/* $MSP_DEST/msp/

  mkdir -p $MSP_DEST/msp/admincerts
  cp $MSP_DEST/msp/signcerts/cert.pem $MSP_DEST/msp/admincerts/
}

# Function to wait for a specific port to be available
function wait_for_port() {
  local port=$1
  echo "⏳ Waiting for port $port to be ready..."
  while ! nc -z localhost "$port"; do
    sleep 1
  done
  echo "✅ Port $port is ready."
}

docker-compose -f docker-compose-ca.yaml up -d

# Wait for all CA servers to be ready
wait_for_port 10054  # ordererorg
wait_for_port 40540  # talentorg
wait_for_port 41540  # companyorg
wait_for_port 42540  # universityorg

enroll_and_register_admin "ordererorg" 10054
enroll_and_register_admin "talentorg" 40540
enroll_and_register_admin "companyorg" 41540
enroll_and_register_admin "universityorg" 42540
