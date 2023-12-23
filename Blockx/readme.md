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
git clone https://github.com/BlockXLabs/BlockX-Genesis-Mainnet1.git
chmod +x blockxd
mv blockxd $HOME/go/bin/
```
### Init
```
MONIKER=
```
```
blockxd init $MONIKER --chain-id blockx_100-1
blockxd config chain-id blockx_100-1
blockxd config keyring-backend file
```
### Custom Port
```
PORT=19
blockxd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.blockxd/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.blockxd/config/app.toml
```
### Genesis

### Peer Seed Gas

### Prunning
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.blockxd/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.blockxd/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.blockxd/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.blockxd/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.blockxd/config/config.toml
```
### Indexer Off
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.blockxd/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/blockxd.service > /dev/null << EOF
[Unit]
Description=Blockxd
After=network-online.target

[Service]
User=$USER
ExecStart=$(which blockxd) start --home $HOME/.blockxd
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
systemctl daemon-reload
systemctl enable blockxd
systemctl restart blockxd
journalctl -fu blockxd -ocat
```
### Sync
```
blockxd status 2>&1 | jq .SyncInfo
```
### Log
```
journalctl -fu blockxd -ocat
```
### Wallet
```
blockxd keys add wallet
```
### List Wallet
```
blockxd keys list
```
### Balances
```
blockxd q bank balances $(blockxd keys show wallet -a)
```




