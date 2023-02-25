```
arkhd status 2>&1 | jq .SyncInfo
```

```
journalctl -u arkhd -f -o cat
```

```
arkhd keys add wallet --recover
```
```
arkhd q bank balances arkh1caclqqep2jprjn0evwyt3jkn6q3zxx4ckkguef
```
```
arkhd tx staking create-validator \
--amount=30000000arkh \
--pubkey=$(arkhd tendermint show-validator) \
--moniker="name" \
--identity=7C66E36EA2B71F68 \
--website=https://nodes.vinjan.xyz \
--details="https://explorer.vinjan.xyz" \
--chain-id=arkh \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-prices=0.1arkh \
--gas-adjustment=1.5 \
--gas=auto \
-y
```






