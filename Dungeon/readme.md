### Binary
```
cd $HOME
rm -rf dungeonchain 
git clone https://github.com/Crypto-Dungeon/dungeonchain.git
cd dungeonchain
git checkout v5.0.0
make install
```
```
mkdir -p $HOME/.dungeonchain/cosmovisor/genesis/bin
cp $HOME/go/bin/dungeond $HOME/.dungeonchain/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.dungeonchain/cosmovisor/genesis $HOME/.dungeonchain/cosmovisor/current -f
sudo ln -s $HOME/.dungeonchain/cosmovisor/current/bin/dungeond /usr/local/bin/dungeond -f
```
```
dungeond version --long | grep -e commit -e version
```

### Init
```
dungeond init <node_name> --chain-id dungeon-1
```

### Custom Port
```
PORT=165
sed -i -e "s%:26657%:${PORT}57%" $HOME/.dungeonchain/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.dungeonchain/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.dungeonchain/config/app.toml
```

### Genesis
```
curl -L https://snap.vinjan.xyz./dungeon/genesis.json > $HOME/.dungeonchain/config/genesis.json
```

### Addrbook
```
curl -L https://snap.vinjan.xyz./dungeon/addrbook.json > $HOME/.dungeonchain/config/addrbook.json
```

###  Gas Prices
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.05udgn\"|" $HOME/.dungeonchain/config/app.toml
```


### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
$HOME/.dungeonchain/config/app.toml
```

### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.dungeonchain/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/dungeond.service > /dev/null << EOF
[Unit]
Description=dungeon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.dungeonchain"
Environment="DAEMON_NAME=dungeond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.dungeonchain/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable dungeond
sudo systemctl restart dungeond
sudo journalctl -u dungeond -f -o cat
```
```
sudo systemctl stop dungeond
cp $HOME/.dungeonchain/data/priv_validator_state.json $HOME/.dungeonchain/priv_validator_state.json.backup
dungeond tendermint unsafe-reset-all --home $HOME/.dungeonchain --keep-addr-book
curl -L https://snap.vinjan.xyz./dungeon/latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.dungeonchain
mv $HOME/.dungeonchain/priv_validator_state.json.backup $HOME/.dungeonchain/data/priv_validator_state.json
sudo systemctl restart dungeond
sudo journalctl -u dungeond -f -o cat
```
```
sudo systemctl stop dungeond
cp $HOME/.dungeonchain/data/priv_validator_state.json $HOME/.dungeonchain/priv_validator_state.json.backup
dungeond tendermint unsafe-reset-all --home $HOME/.dungeonchain --keep-addr-book
SNAP_RPC="https://rpc-dungeon.vinjan.xyz:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.dungeonchain/config/config.toml
mv $HOME/.dungeonchain/priv_validator_state.json.backup $HOME/.dungeonchain/data/priv_validator_state.json
sudo systemctl restart dungeond
sudo journalctl -u dungeond -f -o cat
```
### Sync
```
dungeond status 2>&1 | jq .sync_info
```

### Wallet
```
dungeond keys add wallet
```

### Balances
```
dungeond q bank balances $(dungeond keys show wallet -a)
```

### Validator
```
dungeond tendermint show-validator
nano /root/.dungeonchain/validator.json

{
  "pubkey": ,
  "amount": "100000000udgn",
  "moniker": "",
  "identity": "",
  "website": "",
  "security": "",
  "details": "",
  "commission-rate": "0.05",
  "commission-max-rate": "0.5",
  "commission-max-change-rate": "0.5",
  "min-self-delegation": "1"
}
```
```
dungeond tx staking create-validator $HOME/.dungeonchain/validator.json \
--from wallet \
--chain-id dungeon-1 \
--gas-prices=0.05udgn \
--gas-adjustment=1.5 \
--gas=auto
```

### Delegate
```
dungeond tx staking delegate $(dungeond keys show wallet --bech val -a) 900000udgn --from wallet --chain-id dungeon-1 --gas-adjustment=1.5 --gas-prices=0.05udgn --gas=auto
```
### Withdraw with Commission
```
dungeond tx distribution withdraw-rewards $(dungeond keys show wallet --bech val -a) --commission --from wallet --chain-id dungeon-1 --gas-adjustment=1.5 --gas-prices=0.05udgn --gas=auto
```

### Vote 
```
dungeond tx gov vote 1 yes --from wallet --chain-id dungeon-1 --gas-adjustment=1.5 --gas-prices=0.05udgn --gas=auto
```

### Check Matches
```
[[ $(dungeond q staking validator $(dungeond keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(dungeond status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Own Peer
```
echo $(dungeond tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.dungeonchain/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Delete
```
sudo systemctl stop dungeond
sudo systemctl disable dungeond
sudo rm /etc/systemd/system/dungeond.service
sudo systemctl daemon-reload
rm -f $(which dungeond)
rm -rf $HOME/.dungeonchain
rm -rf $HOME/dungeonchain
```


