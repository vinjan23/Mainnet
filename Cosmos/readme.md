### GO
```
ver="1.22.6"
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
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v21.0.0
make install
```
### Cosmovisor
```
mkdir -p ~/.gaia/cosmovisor/genesis/bin
mkdir -p ~/.gaia/cosmovisor/upgrades
cp ~/go/bin/gaiad ~/.gaia/cosmovisor/genesis/bin
```

### Init
```
gaiad init $MONIKER --chain-id cosmoshub-4
```
### PORT
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:44657\"%" $HOME/.gaia/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:44658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:44657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:44060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:44656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":44660\"%" $HOME/.gaia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:44317\"%; s%^address = \"localhost:9090\"%address = \"localhost:44090\"%" $HOME/.gaia/config/app.toml
```
### Genesis
```
wget -O genesis.json https://snapshots.polkachu.com/genesis/cosmos/genesis.json --inet4-only
mv genesis.json ~/.gaia/config
```
```
wget https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
gzip -d genesis.cosmoshub-4.json.gz
mv genesis.cosmoshub-4.json ~/.gaia/config/genesis.json
```
### Seed Peer
```
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.gaia/config/config.toml
PEERS=
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gaia/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.gaia/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.gaia/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uatom\"/;" ~/.gaia/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.gaia/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/gaiad.service > /dev/null << EOF
[Unit]
Description=gaia
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
Environment="DAEMON_NAME=gaiad"
Environment="DAEMON_HOME=$HOME/.gaia"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo tee /etc/systemd/system/gaiad.service > /dev/null <<EOF
[Unit]
Description=gaia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gaiad) start
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
sudo systemctl enable gaiad
sudo systemctl restart gaiad
sudo journalctl -u gaiad -f -o cat
```
### Sync
```
gaiad status 2>&1 | jq .SyncInfo
```

### Delete
```
sudo systemctl stop gaiad && \
sudo systemctl disable gaiad && \
rm /etc/systemd/system/gaiad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf gaia && \
rm -rf .gaia && \
rm -rf $(which gaiad)
```
