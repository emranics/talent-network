#!/bin/bash

set -e

COMPOSE_FILE=docker-compose-network.yaml

function enable_dev_mode {
  echo "Enabling CORE_CHAINCODE_MODE=dev..."
  sed -i.bak '/# *- CORE_CHAINCODE_MODE=dev/s/^# *//' $COMPOSE_FILE
}

function disable_dev_mode {
  echo "Disabling CORE_CHAINCODE_MODE=dev..."
  sed -i.bak '/^- CORE_CHAINCODE_MODE=dev/s/^/- #/' $COMPOSE_FILE
}

case "$1" in
  enable)
    enable_dev_mode
    ;;
  disable)
    disable_dev_mode
    ;;
  *)
    echo "Usage: $0 {enable|disable}"
    exit 1
    ;;
esac
