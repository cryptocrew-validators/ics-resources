# ICS-resources


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