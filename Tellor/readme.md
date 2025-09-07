```
cd $HOME
rm -rf layer
git clone https://github.com/tellor-io/layer.git
cd layer
git checkout v5.1.1
make install
```
```
mkdir -p $HOME/.layer/cosmovisor/genesis/bin
cp $HOME/go/bin/layerd $HOME/.layer/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.layer/cosmovisor/genesis $HOME/.layer/cosmovisor/current -f
sudo ln -s $HOME/.layer/cosmovisor/current/bin/layerd /usr/local/bin/layerd -f
```
```
layerd init Vinjan>inc --chain-id tellor-1
```
```
curl -Ls https://ss.tellor.nodestake.org/genesis.json > $HOME/.layer/config/genesis.json
```
```
curl -Ls https://ss.tellor.nodestake.org/addrbook.json > $HOME/.layer/config/addrbook.json
```
```
PORT=159
sed -i -e "s%:26657%:${PORT}57%" $HOME/.layer/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.layer/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.layer/config/app.toml
```
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0loya\"|" $HOME/.layer/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.layer/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.layer/config/config.toml
```
```
sudo tee /etc/systemd/system/layerd.service > /dev/null << EOF
[Unit]
Description=tellor
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.layer"
Environment="DAEMON_NAME=layerd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.layer/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable layerd
sudo systemctl restart layerd
sudo journalctl -u layerd -f -o cat
```
```
layerd status 2>&1 | jq .sync_info
```












