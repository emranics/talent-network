#!/bin/bash

set -e

cd talent-chaincode
CORE_CHAINCODE_ID_NAME=talentcc:1.0 npm start -- --peer.address 127.0.0.1:23457
