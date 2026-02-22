###
```
cd $HOME
rm -rf shentu
git clone https://github.com/shentufoundation/shentu.git
cd shentu
git checkout v2.16.2
make install
```
```
mkdir -p $HOME/.shentud/cosmovisor/genesis/bin
cp $HOME/go/bin/shentud $HOME/.shentud/cosmovisor/genesis/bin
```
```
sudo ln -s $HOME/.shentud/cosmovisor/genesis $HOME/.shentud/cosmovisor/current -f
sudo ln -s $HOME/.shentud/cosmovisor/current/bin/shentud /usr/local/bin/shentud -f
```
### 
```
shentud init Vinjan.Inc --chain-id shentu-2.2
```
```
wget -O genesis.json https://snapshots.polkachu.com/genesis/shentu/genesis.json --inet4-only
mv genesis.json ~/.shentud/config
```
```
wget -O addrbook.json https://snapshots.polkachu.com/addrbook/shentu/addrbook.json --inet4-only
mv addrbook.json ~/.shentud/config
```
### 
```
PORT=144
sed -i -e "s%:26657%:${PORT}57%" $HOME/.shentud/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.shentud/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.shentud/config/app.toml
```
###
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.shentud/config/app.toml
```
### 
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.shentud/config/config.toml
```
### 
```
sudo tee /etc/systemd/system/shentud.service > /dev/null << EOF
[Unit]
Description=shentu
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.shentud"
Environment="DAEMON_NAME=shentud"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.shentud/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
###
```
sudo systemctl daemon-reload
sudo systemctl enable shentud
sudo systemctl restart shentud
sudo journalctl -u shentud -f -o cat
```
```
shentud status 2>&1 | jq .sync_info
```
```
shentud q bank balances $(shentud keys show wallet -a)
```
```
shentud comet show-validator
```
```
nano $HOME/.shentud/validator.json
```
```
{
  "pubkey": ,
  "amount": "12000000uctk",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.04",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
shentud tx staking create-validator $HOME/.shentud/validator.json \
--from wallet \
--chain-id shentu-2.2 \
--gas-prices="0.05uctk" \
--gas-adjustment=1.5 \
--gas=auto
```

