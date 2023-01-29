### Auto Install
```
wget -O auto.sh https://raw.githubusercontent.com/vinjan23/Mainnet/main/Stride/auto.sh && chmod +x auto.sh && ./auto.sh
```

### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y make gcc jq curl git lz4 build-essential chrony unzip
```
### Go
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```
### Binary
```
cd || return
rm -rf stride
git clone https://github.com/Stride-Labs/stride.git
cd stride || return
git checkout v5.0.0
make install
```

#### Genesis & Addrbook
```
curl -s https://raw.githubusercontent.com/Stride-Labs/stride/main/genesis/genesis.json > $HOME/.stride/config/genesis.json
curl -s https://snapshots2.nodejumper.io/stride/addrbook.json > $HOME/.stride/config/addrbook.json
```

### Set 
```
MONIKER=
```
### Init
```
strided init $MONIKER --chain-id stride-1
strided config chain-id stride-1
strided config keyring-backend file
strided config node tcp://localhost:16657
```
### Seed & Gas
```
SEEDS=""
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.stride/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0ustrd\"|" $HOME/.stride/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.stride/config/config.toml
```
### Prunning
```
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.stride/config/app.toml
```
### Custom Port
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":16660\"%" $HOME/.stride/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:16317\"%; s%^address = \":8080\"%address = \":16080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:16090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:16091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:16545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:16546\"%" $HOME/.stride/config/app.toml
```

### Create Service
```
sudo tee /etc/systemd/system/strided.service > /dev/null << EOF
[Unit]
Description=Stride Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which strided) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable strided
sudo systemctl start strided
sudo journalctl -u strided -f -o cat
```

### Snapshot
```
wget -O snap.sh https://raw.githubusercontent.com/vinjan23/Mainnet/main/Stride/snap.sh && chmod +x snap.sh && ./snap.sh
```

### Check Sync
```
strided status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u strided -f -o cat
```
### Stop Service
```
sudo systemctl stop strided
```
### Restart
```
sudo systemctl restart strided
```

### Create Wallet
```
strided keys add wallet
```

### Recover
```
strided keys add wallet --recover
```

### List 
```
strided keys list
```



