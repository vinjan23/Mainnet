
```
wget https://github.com/Limonata-Blockchain/limonata/releases/download/v0.4.0-mainnet.3/limonatad-linux-amd64.tar.gz
tar xzf limonatad-linux-amd64.tar.gz
chmod +x limonatad
mv limonatad $HOME/go/bin/
```
```
mkdir -p $HOME/.evmd/cosmovisor/genesis/bin
cp $HOME/go/bin/limonatad $HOME/.evmd/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.evmd/cosmovisor/genesis $HOME/.evmd/cosmovisor/current -f
sudo ln -s $HOME/.evmd/cosmovisor/current/bin/limonatad /usr/local/bin/limonatad -f
```
```
limonatad version --long | grep -e commit -e version -e server_name
```



```
limonatad init Vinjan.Inc --chain-id limonata_20777-1
```
```
PORT=191
sed -i -e "s%:26657%:${PORT}57%" $HOME/.evmd/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.evmd/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%; s%:8545%:${PORT}45%; s%:8546%:${PORT}46%; s%:6065%:${PORT}65%" $HOME/.evmd/config/app.toml
```
```
sed -i -e "s/^chain-id *=.*/chain-id = \"limonata_20777-1\"/;" $HOME/.evmd/config/client.toml
sed -i 's/^evm-chain-id = "262144"/evm-chain-id = "20777"/' $HOME/.evmd/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0aLIMO\"/" $HOME/.evmd/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.evmd/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.evmd/config/config.toml
```
```
sudo tee /etc/systemd/system/limonatad.service > /dev/null <<'EOF'
[Unit]
Description=limonata
After=network-online.target
[Service]
User=vinjan
WorkingDirectory=/home/vinjan
ExecStart=/home/vinjan/go/bin/cosmovisor run start --chain-id limonata_20777-1 --evm.evm-chain-id 20777 --minimum-gas-prices 0aLIMO
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=/home/vinjan/.evmd"
Environment="DAEMON_NAME=limonatad"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable limonatad
sudo systemctl restart limonatad
sudo journalctl -u limonatad -f -o cat
```
