### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install git build-essential curl jq libclang-dev clang cmake gcc -y
```

### GO
```
ver="1.20.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### Bianry
```
cd $HOME
git clone https://github.com/terpnetwork/terp-core.git
cd terp-core
git checkout v1.0.0-stable
make install
```

### Moniker
```
MONIKER=
```

### Init
```
terpd init $MONIKER --chain-id morocco-1
terpd config chain-id morocco-1
terpd config keyring-backend file
```

### Custom Port
```
PORT=46
terpd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.terp/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.terp/config/app.toml
```

### Genesis
```
curl -s https://raw.githubusercontent.com/terpnetwork/mainnet/main/morocco-1/genesis.json > $HOME/.terp/config/genesis.json
```

### Addrbook
```
curl -s https://snapshots2.nodejumper.io/terpnetwork/addrbook.json > $HOME/.terp/config/addrbook.json
```

### Seed & Peers & Gas
```
SEEDS="c71e63b5da517984d55d36d00dc0dc2413d0ce03@seed.terp.network:26656"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.terp/config/config.toml
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.001uterp"|g' $HOME/.terp/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.terp/config/config.toml
```

### Prunning
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.terp/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.terp/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.terp/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.terp/config/app.toml
```

### Service
```
sudo tee /etc/systemd/system/terpd.service > /dev/null << EOF
[Unit]
Description=TerpNetwork Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which terpd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable terpd
sudo systemctl restart terpd
sudo journalctl -u terpd -f -o cat
```

### Sync
```
terpd status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u terpd -f -o cat
```


