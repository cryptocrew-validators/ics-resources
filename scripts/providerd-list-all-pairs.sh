#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <chain-id> <node>"
    echo "Example: $0 cosmoshub-4 http://localhost:26657"
    exit 1
fi

# Assign arguments to variables
CHAIN_ID=$1
NODE=$2

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to retrieve all validators with a large page limit (single fetch)
get_all_validators() {
    log "Fetching all validators from the node with a single request..."
    log "gaiad q staking validators --node $NODE --page-limit 10000 -o json 2>&1"
    # Fetch validators with a high page-limit
    response=$(gaiad q staking validators --node "$NODE" --page-limit 10000 -o json 2>&1)

    # Check if the response is valid JSON
    echo "$response" | jq . > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Failed to parse response from gaiad. Response was: $response"
        exit 1
    fi
    log "$response"
    echo "$response" | jq -c '.validators'
}

# Function to retrieve and display validator information by provider address
get_validator_info() {
    local provider_address=$1
    local consumer_address=$2
    local all_validators=$3

    log "Searching for moniker for provider address: $provider_address"

    # Find and display the validator info based on the provider address
    moniker=$(echo "$all_validators" | jq -r --arg provider_address "$provider_address" '
        .[] | select(.consensus_pubkey.key == $provider_address) | .description.moniker
    ')

    if [ -n "$moniker" ]; then
        echo "Moniker: $moniker"
        echo "Provider Address: $provider_address"
        echo "Consumer Address: $consumer_address"
        log "Moniker found: $moniker for provider address: $provider_address"
        echo ""
    else
        echo "No validator found for provider address: $provider_address"
        echo "Consumer Address: $consumer_address"
        log "No moniker found for provider address: $provider_address"
        echo ""
    fi
}

# Run the initial command to get all pairs of valconsensus addresses
log "Fetching all pairs of valconsensus addresses..."
all_pairs_response=$(gaiad q provider all-pairs-valconsensus-address "$CHAIN_ID" --node "$NODE" -o json 2>&1)

# Check if the response is valid JSON
echo "$all_pairs_response" | jq . > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log "Error: Failed to parse response from gaiad. Response was: $all_pairs_response"
    exit 1
fi

# Get all validators with a single request
all_validators=$(get_all_validators)

# Parse the output and iterate over each provider address
echo "$all_pairs_response" | jq -c '.pair_val_con_addr[]' | while read -r pair; do
    provider_address=$(echo "$pair" | jq -r '.provider_address')
    consumer_address=$(echo "$pair" | jq -r '.consumer_address')

    log "Processing pair: provider_address=$provider_address, consumer_address=$consumer_address"

    # Get the validator info for the current provider address
    get_validator_info "$provider_address" "$consumer_address" "$all_validators"
done

log "Script execution completed."
