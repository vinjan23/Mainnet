### GO
```
ver="1.21.1"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
### Binary
```
cd $HOME
rm -rf stargaze
git clone https://github.com/public-awesome/stargaze stargaze
cd stargaze
git checkout v15.1.0
make install
```
```
mkdir -p $HOME/.starsd/cosmovisor/genesis/bin
cp $HOME/go/bin/starsd $HOME/.starsd/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.starsd/cosmovisor/genesis $HOME/.starsd/cosmovisor/current -f
sudo ln -s $HOME/.starsd/cosmovisor/current/bin/starsd /usr/local/bin/starsd -f
```
```
starsd version --long | grep -e commit -e version
```

### Init
```
starsd config chain-id stargaze-1
```
### Port
```
PORT=32
starsd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.starsd/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.starsd/config/app.toml
```
### Genesis
```
wget -O $HOME/.starsd/config/genesis.json https://snapshots.polkachu.com/genesis/stargaze/genesis.json --inet4-only
```
### Addrbook
```
wget -O $HOME/.starsd/config/addrbook.json https://snapshots.polkachu.com/addrbook/stargaze/addrbook.json --inet4-only
```
### Seed Peer
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"1ustars\"|" $HOME/.starsd/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.starsd/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/starsd.service > /dev/null << EOF
[Unit]
Description=stargaze
After=network-online.target

[Service]
User=$USER
ExecStart=$(which starsd) start
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
sudo systemctl enable starsd
sudo systemctl restart starsd
sudo journalctl -u starsd -f -o cat
```
### Sync
```
starsd status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -u starsd -f -o cat
```
### Snapshot
```
sudo systemctl stop starsd
starsd tendermint unsafe-reset-all --home $HOME/.starsd --keep-addr-book
rm -r ~/.starsd/wasm
wget -O stargaze_9129773.tar.lz4 https://snapshots.polkachu.com/snapshots/stargaze/stargaze_9129773.tar.lz4 --inet4-only
lz4 -c -d stargaze_9129773.tar.lz4  | tar -x -C $HOME/.starsd
sudo systemctl restart starsd
sudo journalctl -u starsd -f -o cat
```
### Add wallet
```
starsd keys add ibc-star
```

### Delete
```
sudo systemctl stop starsd
sudo systemctl disable starsd
sudo rm /etc/systemd/system/starsd.service
sudo systemctl daemon-reload
rm -f $(which starsd)
rm -rf $HOME/.starsd
rm -rf $HOME/stargaze
```

