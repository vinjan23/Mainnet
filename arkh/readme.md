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
--moniker="vinjan" \
--identity=7C66E36EA2B71F68 \
--website=https://nodes.vinjan.xyz \
--details="https://explorer.vinjan.xyz" \
--chain-id=arkh \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallt \
--gas-prices=0.1arkh \
--gas-adjustment=1.5 \
--gas=auto \
-y
```

```
arkhd tx staking edit-validator \
--new-moniker=vinjan \
 --identity=7C66E36EA2B71F68 \
 --website=nodes.vinjan.xyz \
 --details=satsetsatseterror \
 --chain-id=eightball-1 \
 --from=wallt \
 --fees 5000arkh 
 -y
``` 

```
arkhd tx slashing unjail --from <wallet> --chain-id --chain-id arkh --fees 5000arkh -y
```

### WD All
```
arkhd tx distribution withdraw-all-rewards --from wallet --chain-id arkh --fees 5000arkh  -y
```

### WD with commission
```
arkhd tx distribution withdraw-rewards $(arkhd keys show wallet --bech val -a) --commission --from wallet --chain-id arkh --fees 5000arkh  -y
```
### Delegate
```
arkhd tx staking redelegate $(arkhd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 1000000arkh --from wallet --chain-id arkh  --fees 5000arkh  -y
```

### Transfer
```
arkhd tx bank send wallet <TO_WALLET_ADDRESS> 1000000arkh --from wallet --chain-id arkh
```

### Unbond
```
arkhd tx staking unbond $(arkhd keys show wallet --bech val -a) 1000000arkh --from wallet --chain-id arkh --fees 5000arkh  -y
```

### Check Reward
```
arkhd query distribution rewards $(arkhd keys show wallt -a) $(arkhd keys show wallt --bech val -a)
```

### Delete
```
sudo systemctl stop arkhd && \
sudo systemctl disable arkhd && \
rm /etc/systemd/system/arkhd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .arkh && \
rm -rf $(which arkhd)
```

 




