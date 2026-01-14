```
git clone https://github.com/EpixZone/EpixChain.git
cd EpixChain
git checkout v0.5.2
make install
```
```
mkdir -p $HOME/.epixd/cosmovisor/genesis/bin
cp $HOME/go/bin/epixd $HOME/.epixd/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.epixd/cosmovisor/genesis $HOME/.epixd/cosmovisor/current -f
sudo ln -s $HOME/.epixd/cosmovisor/current/bin/epixd /usr/local/bin/epixd -f
```
```
epixd init Vinjan.Inc --chain-id epix_1916-1
```
```
PORT=399
sed -i -e "s%:26657%:${PORT}57%" $HOME/.epixd/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.epixd/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.epixd/config/app.toml
```
```
curl -s https://raw.githubusercontent.com/EpixZone/EpixChain/main/artifacts/genesis/mainnet/genesis.json > ~/.epixd/config/genesis.json
```
```
PEERS="1b7b67ff660e8609ad8dc75149509fafff7bd82b@84.203.116.103:26656"
sed -i "s/persistent_peers = \"\"/persistent_peers = \"$PEERS\"/" ~/.epixd/config/config.toml
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.001aepix"/' ~/.epixd/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.epixd/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.epixd/config/config.toml
```
```
sudo tee /etc/systemd/system/epixd.service > /dev/null << EOF
[Unit]
Description=epix
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.epixd"
Environment="DAEMON_NAME=epixd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.epixd/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable epixd
sudo systemctl restart epixd
sudo journalctl -u epixd -f -o cat
```
```
epixd status 2>&1 | jq .sync_info
```
```
sudo systemctl stop epixd
rm -rf $HOME/.epixd/data
epixd comet unsafe-reset-all --home $HOME/.epixd --keep-addr-book
```
```
sudo systemctl stop epixd
sudo systemctl disable epixd
sudo rm /etc/systemd/system/epixd.service
sudo systemctl daemon-reload
rm -f $(which epixd)
rm -rf .epixd
rm -rf EpixChain
```

