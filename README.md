# ICS-resources

This repository houses useful resources for launching an ICS chain

## Permissionless launch

1. Use [Forge](https://forge.cosmos.network) to register your chain and create a forge.json configuration
2. Use `gaiad tx provider create-consumer <create-consumer.json>` to register your chain on the provider chain --> either set spawn time in the near future or leave empty string and update when everybody has opted in
3. Validators opt in & assign keys
4. OPTIONAL if `spawn_time` was set null in `create-consumer`: Use `gaiad tx provider update-consumer` --> set spawn time to past to force spawn on provider
5. **Genesis time must be max 1 day in the past (or within the trusting period)** --> The genesis block gets finalized with the genesis_time in the header --> if it's longer in the past than the IBC client `trusting_period` the client will be expired upon launch
6. Query CCV state (see below), finalize genesis file
7. Distribute genesis file to validators, launch chain
8. Create CCV channels, start relayer

## Snippets

fetch consumer chain genesis after spawn time has passed
```
CHAINID=rand-1
FRESHGEN=<FRESH-GENESIS-RAW-RUL>
curl -s $FRESHGEN | jq . > fresh.json
gaiad query provider consumer-genesis $CHAINID -o json | jq . > ccv.json
jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' fresh.json ccv.json > genesis.json
sha256sum genesis.json  
```

useful queries:
```
gaiad query provider list-consumer-chains | jq .
gaiad query provider list-stop-proposals | jq .
```

add valcons to tenderduty: find proposed block on mintscan, bech32-convert proposer HEX address to prefixvalcons, add to chains.d