<p align="right">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/108977419/207516348-c160303a-57b0-4149-8118-b0d7785dfde8.jpg">
</p>

<p align="centre">
  <img height="400" height="auto" src="https://user-images.githubusercontent.com/108977419/209762643-3663ef27-d729-4653-aa4d-e70ad386a8c0.jpg">
</p>

### ✅️ Explorer > [Explorer Planq](https://explorer.planq.network/)

#   PLANQ MAINNET

4x CPU

RAM 8 GB

STORAGE 200GB (SSD atau NVME)

### Auto Installation
```
wget -O auto.sh https://raw.githubusercontent.com/vinjan23/Mainnet/main/Planq/auto.sh && chmod +x auto.sh && ./auto.sh
```

### ✅️ Manual Guide > [Manual Guide](https://github.com/vinjan23/Mainnet/blob/main/Planq/README.MD)

### Sync Info
```
planqd status 2>&1 | jq .SyncInfo
```

### Create Wallet
```
planqd keys add <Wallet>
```

### Recover Wallet
```
planqd keys add wallet --recover
```

### List Wallet
```
planqd keys list
```

### Check Balances
 ```
 planqd query bank balances <wallet_address>
 ```
 
### Create Validator
```
planqd tx staking create-validator \
  --amount=1000000000aplanq \
  --pubkey=$(planqd tendermint show-validator) \
  --chain-id=planq_7070-2 \
  --commission-rate="0.05" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1000000" \
  --from=<Wallet>
  --moniker=$NODE_MONIKER \
  --identity=B9FD76B74CE3CA7D \
  --details=satsetsatseterror \
  --gas-adjustment="1.15" \
  --gas-prices 30000000000aplanq \
  --gas 1000000 \
  ```
  
  ### Edit Validator
 ```
planqd tx staking edit-validator \
  --new-moniker=<Your_Moniker> \
  --identity=B9FD76B74CE3CA7D \
  --website="<your_website>" \
  --details=satsetsatseterror \
  --chain-id=planq_7070-2 \
  --from=vj \
  --gas 1000000 \
  --gas-adjustment="1.15" \
  --gas-prices="30000000000aplanq" \
```

### Unjail
```
planqd tx slashing unjail --from <Wallet> --chain-id planq_7070-2 --gas 1000000 --gas-adjustment 1.15 --gas-prices="30000000000aplanq
```

### Delegate & Staking
```
planqd tx staking delegate <YOUR_TO_Validator_ADDRESS> 1000000aplanq --from <Wallet> --chain-id planq_7070-2 --gas-adjustment 1.15 --gas=1000000 --gas-prices=30000000000aplanq 
 
```

### Transfer Fund
```
planqd tx bank send <Wallet> <To_Address> 19950000aplanq --from <Wallet> --chain-id planq_7070-2 --gas-adjustment 1.15 --gas-prices 30000000000aplanq --gas 1000000
```

### Withdraw All Reward
```
planqd tx distribution withdraw-all-rewards --from <WalletName> --chain-id planq_7070-2 --gas-prices 30000000000aplanq --gas-adjustment 1.15 --gas 1000000 
```

### Check Log
```
journalctl -fu planqd -o cat
```

### Node Info
```
planqd status 2>&1 | jq .NodeInfo
```

### Validator Info
```
planqd status 2>&1 | jq .ValidatorInfo
```

### Delete Node
```
sudo systemctl stop planqd && \
sudo systemctl disable planqd && \
rm /etc/systemd/system/planqd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf planq && \
rm -rf .planqd && \
rm -rf $(which planqd)
```


