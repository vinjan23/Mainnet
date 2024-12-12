### GO
```
ver="1.22.6"
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
git clone https://github.com/elys-network/elys
cd elys
git checkout v1.0.0
make install
```
### Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0
```
```
mkdir -p ~/.elys/cosmovisor/genesis/bin
mkdir -p ~/.elys/cosmovisor/upgrades
cp ~/go/bin/elysd ~/.elys/cosmovisor/genesis/bin
```
```
elysd version --long | grep -e commit -e version
```
### Init
```
elysd init Vinjan.Inc --chain-id elys-1
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:16657\"%" $HOME/.elys/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":16660\"%" $HOME/.elys/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:16317\"%; s%^address = \"localhost:9090\"%address = \"localhost:16090\"%" $HOME/.elys/config/app.toml
```

### Genesis
```
wget -O $HOME/.elys/config/genesis.json https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/mainnet/genesis.json
```
```
curl -Ls https://github.com/elys-network/networks/blob/main/mainnet/genesis.json > $HOME/.elys/config/genesis.json  

```
### Addrbook
```
wget -O $HOME/.elys/config/addrbook.json 
```
### Peer
```
peers="949ee3582bab917fc4dd89829871bd46c8b366d8@162.55.245.228:46656,d95bdf717eb751667586b5e31083770630742038@65.109.58.158:22156,380048bb45143b2b87c540c772886f5a08bae344@86.90.185.145:26156,1d079e8b757b21b390f3eca0880ca03f7f90d8f0@95.217.143.167:20656,a0d2b6ed5911c830666cb5ff6df17a0438758e69@38.242.153.88:26656,d71d3bce45274bf8354298042674a08c778f6d27@202.61.243.56:22056"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.elys/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00025uelys\"|" $HOME/.elys/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.elys/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/elysd.service > /dev/null << EOF
[Unit]
Description=elys
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
Environment="DAEMON_NAME=elysd"
Environment="DAEMON_HOME=$HOME/.elys"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable elysd
sudo systemctl restart elysd
sudo journalctl -u elysd -f -o cat
```
### Sync
```
elysd status 2>&1 | jq .sync_info
```
### Wallet
```
elysd keys add wallet --recover
```
### Balances
```
elysd q bank balances $(elysd keys show wallet -a)
```

### Delete
```
sudo systemctl stop elysd
sudo systemctl disable elysd
sudo rm /etc/systemd/system/elysd.service
sudo systemctl daemon-reload
rm -rf $(which elysd)
rm -rf $HOME/.elys
rm -rf $HOME/elys
```



