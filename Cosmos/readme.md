### GO
```
ver="1.20.8"
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
git checkout v12.0.0
make install
```
### Init
```
MONIKER=
```
```
gaiad init $MONIKER --chain-id cosmoshub-4
gaiad config chain-id cosmoshub-4
gaiad config keyring-backend file
```
### PORT
```
PORT=44
gaiad config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.gaia/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.gaia/config/app.toml
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
PEERS=2921ba8e860bae932aef48d0d60d177c9890a656@54.39.28.226:14956,caa07c2c08da83ae9395b89da4957d07976d3be5@43.131.38.11:26656,c5ccf0aaf81e5e523a56bd676822c9f73abcb833@18.143.53.64:26656,7209ec14a9f831baef8f16af9cd7ed69b2e6fc98@95.217.144.107:14956,28d36c3d45f0208528de3c38f2934ae241bd23e7@116.202.140.75:26656
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
