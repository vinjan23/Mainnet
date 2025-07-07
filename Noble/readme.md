
### Binary
```
cd $HOME
rm -rf noble
git clone https://github.com/strangelove-ventures/noble noble
cd noble
git checkout v10.0.0
make build
```
### Cosmovisor
```
mkdir -p $HOME/.noble/cosmovisor/genesis/bin
mv build/nobled $HOME/.noble/cosmovisor/genesis/bin/
rm -rf build
```
```
ln -s $HOME/.noble/cosmovisor/genesis $HOME/.noble/cosmovisor/current -f
sudo ln -s $HOME/.noble/cosmovisor/current/bin/nobled /usr/local/bin/nobled -f
```
### Update Cosmovisor
```
cd $HOME
rm -rf noble
git clone https://github.com/strangelove-ventures/noble noble
cd noble
git checkout v10.0.0
make install
```
```
mkdir -p $HOME/.noble/cosmovisor/upgrades/v10/bin
mv nobled $HOME/.noble/cosmovisor/upgrades/v10/bin/
```
```
cp -a $HOME/go/bin/nobled $HOME/.noble/cosmovisor/upgrades/v10/bin/
```
### Cek version
```
$HOME/.noble/cosmovisor/upgrades/v10/bin/nobled version --long | grep -e commit -e version
```
```
nobled version --long | grep -e commit -e version
```
### Init
```
nobled init Vinjan.Inc --chain-id noble-1
```
### Port
```
PORT=120
sed -i -e "s%:26657%:${PORT}57%" $HOME/.noble/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.noble/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.noble/config/app.toml
```
```
sed -i -e "s%:26657%:12057%" $HOME/.noble/config/client.toml
sed -i -e "s%:26658%:12058%; s%:26657%:12057%; s%:6060%:12060%; s%:26656%:12056%; s%:26660%:12060%" $HOME/.noble/config/config.toml
sed -i -e "s%:1317%:12017%; s%:9090%:12090%" $HOME/.noble/config/app.toml
```

### Genesis
```
wget -O $HOME/.noble/config/genesis.json https://snapshots.polkachu.com/genesis/noble/genesis.json --inet4-only
```
### Addrbook
```
wget -O $HOME/.noble/config/addrbook.json https://snapshots.polkachu.com/addrbook/noble/addrbook.json --inet4-only
```
### Seed
```
sed -i 's/seeds = ""/seeds = "ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:21556"/' ~/.noble/config/config.toml
```
### Gas
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.1uusdc\"|" $HOME/.osmosisd/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.noble/config/app.toml
```

### Service
```
sudo tee /etc/systemd/system/nobled.service > /dev/null << EOF
[Unit]
Description=noble
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.noble"
Environment="DAEMON_NAME=nobled"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.noble/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable nobled
```
```
sudo systemctl restart nobled
```
```
sudo journalctl -u nobled -f -o cat
```
### Sync
```
nobled status 2>&1 | jq .sync_info
```
### Log
```
sudo journalctl -u nobled -f -o cat
```
### Delete
```
sudo systemctl stop nobled
sudo systemctl disable nobled
sudo rm /etc/systemd/system/nobled.service
sudo systemctl daemon-reload
rm -f $(which nobled)
rm -rf $HOME/.noble
rm -rf $HOME/noble
```
