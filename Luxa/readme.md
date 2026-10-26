```
git clone https://github.com/luxaecosystem/luxa-chain.git
cd luxa-chain
git checkout v1.0.0
make install
```
```
mkdir -p $HOME/.luxa/cosmovisor/genesis/bin
cp $HOME/go/bin/luxad $HOME/.luxa/cosmovisor/genesis/bin
```
```
ln -s $HOME/.luxa/cosmovisor/genesis $HOME/.luxa/cosmovisor/current -f
sudo ln -s $HOME/.luxa/cosmovisor/current/bin/luxad /usr/local/bin/luxad -f
```
```
luxad version --long | grep -e commit -e version
```
```
luxad init Vinjan.Inc --chain-id luxa-1
```
```
curl -s https://luxaecosystem.xyz/genesis.json > $HOME/.luxa/config/genesis.json
```
```
curl -L https://snapshot.vinjan-inc.com/luxa/genesis.json > $HOME/.luxa/config/genesis.json
```
```
curl -L https://snapshot.vinjan-inc.com/luxa/addrbook.json > $HOME/.luxa/config/addrbook.json
```
```
PORT=149
sed -i -e "s%:26657%:${PORT}57%" $HOME/.luxa/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.luxa/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.luxa/config/app.toml
```
```
peers="c6eb98f7a65a5fd23ef5c9004d792ec9a8e0b803@51.170.130.74:26656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.luxa/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001uluxa\"/" $HOME/.luxa/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.luxa/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.luxa/config/config.toml
```
```
sudo tee /etc/systemd/system/luxad.service > /dev/null << EOF
[Unit]
Description=luxa
After=network-online.target
[Service]
User=vinjan
WorkingDirectory=/home/vinjan
ExecStart=/home/vinjan/go/bin/cosmovisor run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=/home/vinjan/.luxa"
Environment="DAEMON_NAME=luxad"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo tee /etc/systemd/system/luxad.service > /dev/null << EOF
[Unit]
Description=luxa
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.luxa"
Environment="DAEMON_NAME=luxad"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable luxad
sudo systemctl restart luxad
sudo journalctl -u luxad -f -o cat
```
```
luxad status 2>&1 | jq .sync_info
```

