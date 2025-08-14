
### Binary Build
```
cd $HOME
rm -rf gaia
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v25.1.0
make build
```
### Cosmovisor
```
mkdir -p $HOME/.gaia/cosmovisor/genesis/bin
mv build/gaiad $HOME/.gaia/cosmovisor/genesis/bin/
rm -rf build
```
```
ln -s $HOME/.gaia/cosmovisor/genesis $HOME/.gaia/cosmovisor/current -f
sudo ln -s $HOME/.gaia/cosmovisor/current/bin/gaiad /usr/local/bin/gaiad -f
```
### Install
```
cd $HOME
rm -rf gaia
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v25.1.0
make install
```
```
mkdir -p $HOME/.gaia/cosmovisor/genesis/bin
cp $HOME/go/bin/gaiad $HOME/.gaia/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.gaia/cosmovisor/genesis $HOME/.gaia/cosmovisor/current -f
sudo ln -s $HOME/.gaia/cosmovisor/current/bin/gaiad /usr/local/bin/gaiad -f
```
### Upgrade
```
cd $HOME
rm -rf gaia
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v25.1.0
make build
```
```
mkdir -p $HOME/.gaia/cosmovisor/upgrades/v25.1.0/bin
mv build/gaiad $HOME/.gaia/cosmovisor/upgrades/v25.1.0/bin/
rm -rf build
```
```
cd $HOME
rm -rf gaia
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v25.1.0
make install
```
```
mkdir -p $HOME/.gaia/cosmovisor/upgrades/v25.1.0/bin
cp $HOME/go/bin/gaiad $HOME/.gaia/cosmovisor/upgrades/v25.1.0/bin/
```
```
ls -l $HOME/.gaia/cosmovisor/current
rm $HOME/.gaia/cosmovisor/current
ln -s $HOME/.gaia/cosmovisor/upgrades/v25.1.0 $HOME/.gaia/cosmovisor/current
```
```
mkdir -p $HOME/.gaia/cosmovisor/upgrades/v25.1.0/bin
cp $HOME/go/bin/gaiad $HOME/.gaia/cosmovisor/upgrades/v23/bin/
```
### Cek version
```
$HOME/.gaia/cosmovisor/upgrades/v25.1.0/bin/gaiad version --long | grep -e commit -e version
```
`cc8fa2b`

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
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.005uatom\"/;" ~/.gaia/config/app.toml
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
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.gaia"
Environment="DAEMON_NAME=gaiad"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.gaia/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable gaiad
```
```
sudo systemctl restart gaiad
sudo journalctl -u gaiad -f -o cat
```
### Sync
```
gaiad status 2>&1 | jq .sync_info
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
