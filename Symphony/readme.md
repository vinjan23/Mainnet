### Binary
```
cd $HOME
rm -rf symphony
git clone https://github.com/Orchestra-Labs/symphony.git
cd symphony
git checkout v1.0.0
make install
```
```
mkdir -p $HOME/.symphonyd/cosmovisor/genesis/bin
cp $HOME/go/bin/symphonyd $HOME/.symphonyd/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.symphonyd/cosmovisor/genesis $HOME/.symphonyd/cosmovisor/current -f
sudo ln -s $HOME/.symphonyd/cosmovisor/current/bin/symphonyd /usr/local/bin/symphonyd -f
```
### Upgrade
```
cd $HOME
rm -rf symphony
git clone https://github.com/Orchestra-Labs/symphony.git
cd symphony
git checkout v1.0.4
make build
```
```
mkdir -p $HOME/.symphonyd/cosmovisor/upgrades/v28/bin
cp build/symphonyd $HOME/.symphonyd/cosmovisor/upgrades/v28/bin/
```
```
$HOME/.symphonyd/cosmovisor/upgrades/v28/bin/symphonyd version --long | grep -e commit -e version
```
```
symphonyd version --long | grep -e commit -e version
```
### Init
```
symphonyd init $MONIKER --chain-id symphony-1
```
### Port
```
sed -i -e "s%:26657%:21657%" $HOME/.symphonyd/config/client.toml
sed -i -e "s%:26658%:21658%; s%:26657%:21657%; s%:6060%:21060%; s%:26656%:21656%; s%:26660%:21660%" $HOME/.symphonyd/config/config.toml
sed -i -e "s%:1317%:21317%; s%:9090%:21090%" $HOME/.symphonyd/config/app.toml
```

### Genesis
```
wget -O $HOME/.symphonyd/config/genesis.json https://raw.githubusercontent.com/Orchestra-Labs/symphony/refs/heads/main/networks/symphony-1/genesis.json
```
### Addrbook
```
curl -L https://snap.vinjan.xyz/symphony/addrbook.json > $HOME/.symphonyd/config/addrbook.json
```
### Seed
```
seeds="2a13b793b60db04677911f58e12d80854dd49c49@65.21.234.111:21656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.symphonyd/config/config.toml
```
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025note\"/" $HOME/.symphonyd/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "1000"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "11"|' \
$HOME/.symphonyd/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.symphonyd/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/symphonyd.service > /dev/null << EOF
[Unit]
Description=symphony
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
Environment="DAEMON_NAME=symphonyd"
Environment="DAEMON_HOME=$HOME/.symphonyd"
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
sudo systemctl enable symphonyd
sudo systemctl restart symphonyd
sudo journalctl -u symphonyd -f -o cat
```
### Sync
```
symphonyd status 2>&1 | jq .sync_info
```
### Node Info
```
symphonyd status 2>&1 | jq .node_info
```
```
echo $(symphonyd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.symphonyd/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
```
798fd108b9a0e696bdacd6e7ea7a3fe20c11eafd@65.21.234.111:26656
```
### Edit Validator
```
symphonyd tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Staking Provider-IBC Relayer" \
--chain-id=symphony-1 \
--from=wallet \
--commission-rate=0.15 \
--gas-adjustment 1.5 \
--gas-prices 0.0025note \
--gas auto
```
### WD Commission
```
symphonyd tx distribution withdraw-rewards $(symphonyd keys show wallet --bech val -a) --commission --from wallet --chain-id symphony-1 --gas-adjustment 1.5 --gas-prices 0.0025note --gas auto
```
### Stake
```
symphonyd tx staking delegate $(symphonyd keys show wallet --bech val -a) 1000000note --from wallet --chain-id symphony-1 --gas-adjustment 1.5 --gas-prices 0.0025note --gas auto
```
### Transfer
```
symphonyd tx bank send wallet <TO_WALLET_ADDRESS> 1000000note --from wallet ---chain-id symphony-1 --gas-adjustment 1.5 --gas-prices 0.0025note --gas auto
```

### Snapshot
```
sudo systemctl stop symphonyd
cp $HOME/.symphonyd/data/priv_validator_state.json $HOME/.symphonyd/priv_validator_state.json.backup
rm -rf $HOME/.symphonyd/data
curl -L https://snap.vinjan.xyz/symphony/latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.symphonyd
mv $HOME/.symphonyd/priv_validator_state.json.backup $HOME/.symphonyd/data/priv_validator_state.json
sudo systemctl restart symphonyd
sudo journalctl -u symphonyd -f -o cat
```
```
curl -L https://snapshot.vinjan.xyz/symphony/genesis.json > $HOME/.symphony/config/genesis.json
```
```
cp $HOME/.symphonyd/config/addrbook.json /var/www/snapshot/symphony/addrbook.json
```
```
curl -L https://snapshot.vinjan.xyz/symphony/addrbook.json > $HOME/.symphonyd/config/addrbook.json
```
### Cek Snapshot
```
du -h /var/www/snap/symphony/latest.tar.lz4|cut -f1
```

### Delete
```
sudo systemctl stop symphonyd
sudo systemctl disable symphonyd
sudo rm /etc/systemd/system/symphonyd.service
sudo systemctl daemon-reload
rm -f $(which symphonyd)
rm -rf .symphonyd
rm -rf symphony
```
