### Binary
```
cd $HOME
rm -rf xpex-chain
git clone --branch v1.0.0 https://github.com/tutu4881/xpex-chain
cd xpex-chain
go mod tidy
go build -o xpexd ./exampled
mv xpexd $HOME/go/bin/
```
```
xpexd init Vinjan.Inc --chain-id xpex-2
```
```
curl -L -o ~/.exampleapp/config/genesis.json https://raw.githubusercontent.com/tutu4881/xpex-chain/v1.0.0/railway-config/config/genesis.json
```
```
xpexd version  --long | grep -e version -e commit
```
```
sed -i 's|^persistent_peers = .*|persistent_peers = "3887d9d589f6ae75d149ed62504a539405dc03aa@95.216.102.220:11356"|' ~/.exampleapp/config/config.toml
sed -i 's|^minimum-gas-prices = .*|minimum-gas-prices = "0uxpx"|' ~/.exampleapp/config/app.toml
```
### Port
```
PORT=113
sed -i -e "s%:26657%:${PORT}57%" $HOME/.exampleapp/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.exampleapp/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%; s%:8545%:${PORT}45%; s%:8546%:${PORT}46%; s%:6065%:${PORT}65%" $HOME/.exampleapp/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.exampleapp/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.exampleapp/config/config.toml
```
### Create Service
```
sudo tee /etc/systemd/system/xpexd.service > /dev/null <<EOF
[Unit]
Description=XPEX node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which xpexd) start --minimum-gas-prices 0uxpx
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable xpexd
sudo systemctl restart xpexd
sudo journalctl -u xpexd -f -o cat
```

### Sync
```
xpexd  status 2>&1 | jq .sync_info
```

### Wallet
```
xpexd keys add wallet
```
```
xpexd q bank balances $(xpexd keys show wallet -a)
```
### Validator
```
xpexd comet show-validator
```
```
nano $HOME/.exampleapp/validator.json
```
10000000000
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"r+JZVxgttqVV60Cc82R+OfqcLISdn+93RO7wf/67/nY="},
  "amount": "9000000000uxpx",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.1",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
xpexd tx staking create-validator $HOME/.exampleapp/validator.json \
--from wallet \
--chain-id xpex-2 \
--gas-prices=0uxpx \
--gas=auto
```
### Edit
```
xpexd tx staking edit-validator \
--new-moniker="" \
--identity="" \
--from=wallet \
--chain-id xpex-2 \
--gas-prices=0uxpx \
--gas=auto
```

### WD
```
xpexd tx distribution withdraw-rewards $(xpexd keys show wallet --bech val -a) --commission --from wallet --chain-id xpex-2 --gas-prices=0uxpx --gas=auto
```
### Delegate
```
xpexd tx staking delegate $(xpexd keys show wallet --bech val -a) 10000000000uxpx --from wallet --chain-id xpex-2 --gas-prices=0uxpx --gas=auto
```
### Own Peer
```
echo $(xpexd comet show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.exampleapp/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Delete
```
sudo systemctl stop xpexd
sudo systemctl disable xpexd
sudo rm /etc/systemd/system/xpexd.service
sudo systemctl daemon-reload
rm -rf $(which xpexd)
rm -rf .exampleapp
rm -rf xpex-chain
```
