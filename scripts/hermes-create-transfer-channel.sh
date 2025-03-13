#!/bin/bash

# Create TRANSFER channels

# CONSUMER_CLIENT_ID is on CONSUMER upon genesis
CONSUMER_CONNECTION_ID="<YOUR-CONSUMERCHAIN-IBC-CONNECTION-ID>"
CONSUMER_CHAIN_ID="<YOUR-CONSUMERCHAIN-ID>"

# PROVIDER_CLIENT_ID is created on PROVIDER upon CONSUMER spawn time: gaiad q provider list-consumer-chains
PROVIDER_CLIENT_ID="<YOUR-PROVIDERCHAIN-IBC-CLIENT-ID>"
PROVIDER_CHAIN_ID="<YOUR-PROVIDERCHAIN-ID>"

CONFIG=$1
if [ -z "$CONFIG" ]; then 
    CONFIG=$HOME/.hermes/config.toml
fi
if [ ! -f "$CONFIG" ]; then
    echo "no config file found at $CONFIG"
    exit 1
fi

output=$(hermes --json --config $CONFIG create channel --a-chain $CONSUMER_CHAIN_ID --a-port transfer --b-port transfer --order ordered --a-connection $CONSUMER_CONNECTION_ID --channel-version 1 | tee /dev/tty)
json_output=$(echo "$output" | grep 'result')
echo "---- DONE ----"
echo "$json_output" | jq

# hermes startconsumer
