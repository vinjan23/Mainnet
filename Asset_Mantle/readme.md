### Update
```
sudo apt update
sudo apt install -y curl git jq lz4 build-essential unzip
```

### GO
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

### Binary
```
cd || return
rm -rf node
git clone https://github.com/AssetMantle/node.git
cd node || return
git checkout v0.3.1
make install
```

### Set moniker
```
MONIKER=Your_NODENAME 
```

### Init
```
PORT=42
mantleNode config chain-id mantle-1
mantleNode init "$MONIKER" --chain-id mantle-1
mantleNode config keyring-backend file
mantleNode config node tcp://localhost:${PORT}657
```

###
```
curl -s https://raw.githubusercontent.com/AssetMantle/genesisTransactions/main/mantle-1/final_genesis.json > $HOME/.mantleNode/config/genesis.json
curl -s https://snapshots1.nodejumper.io/assetmantle/addrbook.json > $HOME/.mantleNode/config/addrbook.json
```

### Seed & Peers
```
SEEDS="10de5165a61dd83c768781d438748c14e11f4397@seed.assetmantle.one:26656"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.mantleNode/config/config.toml

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.mantleNode/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.mantleNode/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.mantleNode/config/app.toml

sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.001umntl"|g' $HOME/.mantleNode/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.mantleNode/config/config.toml
```

### Custom Port
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.mantleNode/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.mantleNode/config/app.toml
```
### Create System
```
sudo tee /etc/systemd/system/mantleNode.service > /dev/null << EOF
[Unit]
Description=AssetMantle Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which mantleNode) start --x-crisis-skip-assert-invariants
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

### Snapshot
```
mantleNode unsafe-reset-all
curl -s https://snapshots1.nodejumper.io/assetmantle/addrbook.json > $HOME/.mantleNode/config/addrbook.json

SNAP_RPC="https://assetmantle.nodejumper.io:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i 's|^enable *=.*|enable = true|' $HOME/.mantleNode/config/config.toml
sed -i 's|^rpc_servers *=.*|rpc_servers = "'$SNAP_RPC,$SNAP_RPC'"|' $HOME/.mantleNode/config/config.toml
sed -i 's|^trust_height *=.*|trust_height = '$BLOCK_HEIGHT'|' $HOME/.mantleNode/config/config.toml
sed -i 's|^trust_hash *=.*|trust_hash = "'$TRUST_HASH'"|' $HOME/.mantleNode/config/config.toml
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable mantleNode
sudo systemctl restart mantleNode
sudo journalctl -fu mantleNode -o cat
```

### Sync
```
mantleNode status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -fu mantleNode -o cat
```

### Create Wallet
```
mantleNode keys add wallet
```
### Recover
```
mantleNode keys add wallet --recover
```
### List Wallet
```
mantleNode keys list
```

### Check Balance
```
mantleNode q bank balances $(mantleNode keys show wallet -a)
```

### Create Validator
```
mantleNode tx staking create-validator \
--amount=1000000umntl \
--pubkey=$(mantleNode tendermint show-validator) \
--moniker="vinjan" \
--identity=7C66E36EA2B71F68 \
--website=nodes.vinjan.xyz \
--details="https://explorer.vinjan.xyz" \
--chain-id=mantle-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-prices=0.1umntl \
--gas-adjustment=1.5 \
--gas=auto \
-y 
```

### Edit
```
mantleNode tx staking edit-validator \
--new-moniker="Moniker" \
--identity= \
--details= \
--chain-id=mantle-1 \
--from=wallet \
--gas-prices=0.1umntl \
--gas-adjustment=1.5 \
--gas=auto \
-y 
```

### Unjail
```
mantleNode tx slashing unjail --from wallet --chain-id mantle-1 --gas-prices 0.1umntl --gas-adjustment 1.5 --gas auto -y 
```

### Delegate
```
mantleNode tx staking delegate YOUR_TO_VALOPER_ADDRESS 1000000umntl --from wallet --chain-id mantle-1 --gas-prices 0.1umntl --gas-adjustment 1.5 --gas auto -y 
```

### Withdraw Reward
```
mantleNode tx distribution withdraw-all-rewards --from wallet --chain-id mantle-1 --gas-prices 0.1umntl --gas-adjustment 1.5 --gas auto -y 
```

### Withdraw with Commision
```
mantleNode tx distribution withdraw-rewards $(mantleNode keys show wallet --bech val -a) --commission --from wallet --chain-id mantle-1 --gas-prices 0.1umntl --gas-adjustment 1.5 --gas auto -y 
```

### Transfer
```
mantleNode tx bank send wallet YOUR_TO_WALLET_ADDRESS 1000000umntl --from wallet --chain-id mantle-1 --gas-prices 0.1umntl --gas-adjustment 1.5 --gas auto -y 
```

### Unbond/Unstake
```
mantleNode tx staking unbond $(mantleNode keys show wallet --bech val -a) 1000000umntl --from wallet --chain-id mantle-1 --gas-prices 0.1umntl --gas-adjustment 1.5 --gas auto -y 
```

### Validator Info
```
mantleNode status 2>&1 | jq .ValidatorInfo
```

### Stop 
```
sudo systemctl stop mantleNode
```

### Restart
```
sudo systemctl restart mantleNode
```
### Check Validator Match with Wallet
```
[[ $(mantleNode q staking validator $(mantleNode keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(mantleNode status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Delete Node
```
sudo systemctl stop mantleNode
sudo systemctl disable mantleNode
sudo rm /etc/systemd/system/mantleNode.service
sudo systemctl daemon-reload
rm -rf $HOME/.mantleNode
rm -rf $HOME/node
sudo rm $(which mantleNode)
```




