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
sudo systemctl start mantleNode
sudo journalctl -fu mantleNode -o cat
```

