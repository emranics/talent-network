#!/bin/bash

set -e

source ./scripts/env.sh

# Function to wait for a specific port to be available
function wait_for_port() {
  local port=$1
  echo "⏳ Waiting for port $port to be ready..."
  while ! nc -z localhost "$port"; do
    sleep 1
  done
  echo "✅ Port $port is ready."
}

docker-compose -f docker-compose-network.yaml up -d

# Wait for Orderer and all peers
wait_for_port 11500  # Orderer
wait_for_port 45540  # peer0.talentorg
wait_for_port 20510  # peer0.universityorg
wait_for_port 30510  # peer0.companyorg
