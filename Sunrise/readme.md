### Binary
```
cd $HOME
rm -rf sunrise
git clone https://github.com/sunriselayer/sunrise.git
cd sunrise
git checkout v1.1.0-make-install
make install
```
```
mkdir -p $HOME/.sunrise/cosmovisor/genesis/bin
cp $HOME/go/bin/sunrised $HOME/.sunrise/cosmovisor/genesis/bin
```
```
sudo ln -s $HOME/.sunrise/cosmovisor/genesis $HOME/.sunrise/cosmovisor/current -f
sudo ln -s $HOME/.sunrise/cosmovisor/current/bin/sunrised /usr/local/bin/sunrised -f
```
### Upgrade
```
cd $HOME
rm -rf sunrise
git clone https://github.com/sunriselayer/sunrise.git
cd sunrise
git checkout v1.2.0
make install
```
```
mkdir -p $HOME/.sunrise/cosmovisor/upgrades/v1.2.0/bin
cp -a $HOME/go/bin/sunrised $HOME/.sunrise/cosmovisor/upgrades/v1.2.0/bin/
```
```
$HOME/.sunrise/cosmovisor/upgrades/v1.2.0/bin/sunrised version --long | grep -e commit -e version
```
```
sunrised version --long | grep -e commit -e version
```
### Init
```
sunrised init Vinjan.Inc --chain-id sunrise-1
```
### Genesis
```
wget -O $HOME/.soarchain/config/genesis.json https://raw.githubusercontent.com/soar-robotics/mainnet-rehearsal/main/network/pregenesis.json
```
```
wget -O $HOME/.soarchain/config/genesis.json "https://raw.githubusercontent.com/soar-robotics/mainnet-rehearsal/main/network/genesis.json"
```
### Port
```
PORT=189
sed -i -e "s%:26657%:${PORT}57%" $HOME/.sunrise/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.sunrise/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.sunrise/config/app.toml
```
### Gas
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"1000uusdrise\"/" $HOME/.sunrise/config/app.toml
```
### Prunning
```
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
  $HOME/.sunrise/config/app.toml
```
### Indexer
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.sunrise/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/sunrised.service > /dev/null << EOF
[Unit]
Description=sunrise
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.sunrise"
Environment="DAEMON_NAME=sunrised"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.sunrise/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable sunrised
sudo systemctl restart sunrised
sudo journalctl -u sunrised -f -o cat
```
### Sync
```
sunrised status 2>&1 | jq .sync_info
```
### Add Wallet
```
sunrised keys add wallet --recover
```

### Balances
```
sunrised q bank balances $(sunrised keys show wallet -a)
```
###
```
sunrised comet show-validator
```
```
nano /root/.sunrise/validator.json
```
```
{
  "pubkey": },
  "amount": "",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.05",
  "min-self-delegation": "1"
}
```
```
sunrised tx staking create-validator $HOME/.sunrise/validator.json \
--from=wallet \
--chain-id sunrise-1 \
--fees 1000uusdrise \
--gas auto
```
```
sunrised tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--details="Staking Provider-IBC Relayer" \
--commission-rate=0.12 \
--chain-id=sunrise-1 \
--from=wallet \
--gas-prices 0.002uusdrise \
--gas 400000
```
### WD
```
sunrised tx distribution withdraw-rewards $(sunrised keys show wallet --bech val -a) --commission --from wallet --chain-id sunrise-1 --fees 1000uusdrise --gas auto
```
```
sunrised tx distribution withdraw-rewards $(sunrised keys show wallet --bech val -a) --commission --from wallet --chain-id sunrise-1 --gas 400000 --gas-prices 0.002uusdrise
```
### Stake
```
sunrised tx staking delegate $(sunrised keys show wallet --bech val -a) 1000000uvrise --from wallet --chain-id sunrise-1 -gas 400000 --gas-prices 0.002uusdrise
```
### Send
```
sunrised tx bank send wallet <TO_WALLET_ADDRESS> 500000uusdrise --from wallet ---chain-id sunrise-1 --fees 10000uusdrise --gas auto
```
```
sunrised tx bank send wallet sunrise1ak359erq6xq8v8c8k8pg5yprfl0e0s6n4wp9mr 100000uusdrise --from wallet --chain-id sunrise-1 --gas 200000 --gas-prices 0.002uusdrise
```

### Vote
```
sunrised tx gov vote 14 yes --from wallet --chain-id sunrise-1 --fees 1000uusdrise --gas auto
```
```
sudo systemctl stop sunrised
sudo systemctl disable sunrised
sudo rm /etc/systemd/system/sunrised.service
sudo systemctl daemon-reload
rm -f $(which sunrised)
rm -rf .sunrise
rm -rf sunrise
```
