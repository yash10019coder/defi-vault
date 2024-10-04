#!/bin/bash

set -e # exit on first error

function check_error {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

function build_deploy_sc_and_node() {

# check if all dependencies are installed
yarn
check_error "yarn failed"

echo "Successfully installed dependencies"

# compile contracts
yarn hardhat compile
check_error "hardhat compile failed"

echo "Successfully compiled contracts"

# check if port 8545 is free
if lsof -Pi :8545 -sTCP:LISTEN -t >/dev/null ; then
  echo "Port 8545 is already in use"
  echo "Node is already deployed."
else
# start local node
  yarn hardhat node &
  check_error "hardhat node failed"
fi


# deploy contracts
if ! yarn deploy-ethers
then
  echo "hardhat run scripts/deploy.js failed"
  kill_node
  exit 1
else
  echo "Successfully deployed contracts"
  fi
}

function kill_node() {
  kill %1
}

build_deploy_sc_and_node