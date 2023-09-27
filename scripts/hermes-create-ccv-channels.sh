#!/bin/bash

# CONSUMER_CLIENT_ID is on CONSUMER upon genesis
CONSUMER_CLIENT_ID="<YOUR-CONSUMERCHAIN-IBC-CLIENT-ID>"
CONSUMER_CHAIN_ID="<YOUR-CONSUMERCHAIN-ID>"

# PROVIDER_CLIENT_ID is created on PROVER upon CONSUMER spawn time: gaiad q provider list-consumer-chains
PROVIDER_CLIENT_ID="<YOUR-PROVIDERCHAIN-IBC-CLIENT-ID>"
PROVIDER_CHAIN_ID="<YOUR-PROVIDERCHAIN-ID>"

# CONSUMER_CLIENT_ID is on CONSUMER upon genesis
CONSUMER_CLIENT_ID="07-tendermint-126"
CONSUMER_CHAIN_ID="pion-1"

# PROVIDER_CLIENT_ID is created on PROVER upon CONSUMER spawn time: gaiad q provider list-consumer-chains
PROVIDER_CLIENT_ID="07-tendermint-48"
PROVIDER_CHAIN_ID="provider"


CONFIG=$1
if [ -z "$CONFIG" ]; then 
    CONFIG=$HOME/.hermes/config.toml
fi
if [ ! -f "$CONFIG" ]; then
    echo "no config file found at $CONFIG"
    exit 1
fi

output=$(hermes --json --config $CONFIG create connection --a-chain $CONSUMER_CHAIN_ID --a-client $CONSUMER_CLIENT_ID --b-client $PROVIDER_CLIENT_ID | tee /dev/tty)
json_output=$(echo "$output" | grep 'result')
a_side_connection_id=$(echo "$json_output" | jq -r '.result.a_side.connection_id')
output=$(hermes --json --config $CONFIG create channel --a-chain $CONSUMER_CHAIN_ID --a-port consumer --b-port provider --order ordered --a-connection $a_side_connection_id --channel-version 1 | tee /dev/tty)
json_output=$(echo "$output" | grep 'result')
echo "---- DONE ----"
echo "$json_output" | jq

# hermes start