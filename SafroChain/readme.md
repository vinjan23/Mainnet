### Bianry
```
cd $HOME
rm -rf safrochain-node
git clone https://github.com/Safrochain-Org/safrochain-node.git
cd safrochain-node
git fetch --tags
git checkout v0.2.2
make install
```

```
mkdir -p $HOME/.safrochain/cosmovisor/genesis/bin
cp $HOME/go/bin/safrochaind $HOME/.safrochain/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.safrochain/cosmovisor/genesis $HOME/.safrochain/cosmovisor/current -f
sudo ln -s $HOME/.safrochain/cosmovisor/current/bin/safrochaind /usr/local/bin/safrochaind -f
```
```
sha256sum $HOME/go/bin/safrochaind
```
### Init
```
safrochaind init Vinjan.inc --chain-id safrochain-1
```
```
safrochaind version  --long | grep -e version -e commit
```
### Genesis
```
wget -O $HOME/.safrochain/config/genesis.json https://raw.githubusercontent.com/Safrochain-Org/mainnet-genesis/refs/heads/main/genesis.json
```
```
safrochaind genesis validate --home ~/.safrochain
```
```
sha256sum $HOME/.safrochain/config/genesis.json
```

### Port
```
PORT=127
sed -i -e "s%:26657%:${PORT}57%" $HOME/.safrochain/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.safrochain/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%; s%:8545%:${PORT}45%; s%:8546%:${PORT}46%; s%:6065%:${PORT}65%" $HOME/.safrochain/config/app.toml
```
### Config
```
peers="3aafa25bae84b2bbcbf7ead5400474a623727fe3@@peer-safrochain.vinjan-inc.com:12756"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.safrochain/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"10000usaf\"/" $HOME/.safrochain/config/app.toml
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "default"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.safrochain/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.safrochain/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/safrochaind.service > /dev/null << EOF
[Unit]
Description=safrochain
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.safrochain"
Environment="DAEMON_NAME=safrochaind"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.safrochain/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable safrochaind
sudo systemctl restart safrochaind
sudo journalctl -u safrochaind -f -o cat
```

### Sync
```
safrochaind status 2>&1 | jq .sync_info
```
### Wallet
```
safrochaind keys add wallet
```
### Balances
```
safrochaind q bank balances $(safrochaind keys show wallet -a)
```
### Validator
```
safrochaind comet show-validator
```
```
nano $HOME/.safrochain/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"vIfyVKtXPyoZbN3ZtmcPcE357hHCY2jkZgFH1f+GXYk="},
  "amount": "9000000000usaf",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.1",
  "commission-max-change-rate": "0.5",
  "commission-max-rate": "0.5",
  "min-self-delegation": "1"
}
```
```
safrochaind tx staking create-validator $HOME/.safrochain/validator.json \
--from wallet \
--chain-id safrochain-1 \
--fees 10000usaf
--gas-prices 0.05usaf \
--gas-adjustment 1.3 \
--gas auto
```

### Unjail
```
safrochaind tx slashing unjail --from wallet --chain-id safro-preprod-1 --gas-prices 0.05usaf --gas-adjustment 1.5 --gas auto
```

### Wd
```
safrochaind tx distribution withdraw-rewards $(safrochaind keys show wallet --bech val -a) --commission --from wallet --chain-id safro-preprod-1 --gas-prices 0.05usaf --gas-adjustment 1.5 --gas auto
```

### Delegate
```
safrochaind tx staking delegate $(safrochaind keys show wallet --bech val -a) 1000000usaf --from wallet --chain-id safro-preprod-1 --gas-prices 0.05usaf --gas-adjustment 1.5 --gas auto
```
ID
```
echo $(safrochaind comet show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.safrochain/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
```
safrochaind tx bank send wallet addr_safro1sdlfp8n5fcfa7qw7770ngqs02k876gf6dq7aw5 1005000000usaf --from wallet --chain-id safro-preprod-1 --fees 10000usaf
```
```
safrochaind tx gov vote 4 yes --from wallet --chain-id safro-preprod-1 --gas-prices 0.05usaf --gas-adjustment 1.5 --gas auto
```
### Delete
```
sudo systemctl stop safrochaind 
sudo systemctl disable safrochaind
sudo rm /etc/systemd/system/safrochaind.service
sudo systemctl daemon-reload
rm -rf $(which safrochaind)
rm -rf .safrochain
rm -rf safrochain-node
```







