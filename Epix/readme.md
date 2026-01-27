```
cd $HOME
rm -rf epix
git clone https://github.com/EpixZone/EpixChain.git
cd epix
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
wget https://github.com/EpixZone/EpixChain/releases/download/v0.5.2-fix/epixd
mkdir -p $HOME/.epixd/cosmovisor/upgrades/v0.5.2/bin
cp epixd $HOME/.epixd/cosmovisor/upgrades/v0.5.2/bin/
```
```
chmod +x $HOME/.epixd/cosmovisor/upgrades/v0.5.2/bin/epixd
```
### Upgrade
```
cd $HOME
rm -rf epix
git clone https://github.com/EpixZone/EpixChain.git
cd EpixChain
git checkout v0.5.3
make install
```
```
mkdir -p $HOME/.epixd/cosmovisor/upgrades/v0.5.3/bin
cp $HOME/go/bin/epixd $HOME/.epixd/cosmovisor/upgrades/v0.5.3/bin/
```
```
$HOME/.epixd/cosmovisor/upgrades/v0.5.3/bin/epixd version --long | grep -e commit -e version
```
```
epixd version --long | grep -e commit -e version
```

```
epixd init Vinjan.Inc --chain-id epix_1916-1
epixd config set client chain-id epix_1916-1
```
```
PORT=399
sed -i -e "s%:26657%:${PORT}57%" $HOME/.epixd/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.epixd/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.epixd/config/app.toml
```
```
curl -L https://snapshot.vinjan-inc.com/epix/genesis.json > $HOME/.epixd/config/genesis.json
```
```
curl -L https://snapshot.vinjan-inc.com/epix/addrbook.json > $HOME/.epixd/config/addrbook.json
```
```
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
epixd q bank balances $(epixd keys show wallet -a)
```
```
epixd comet show-validator
```
```
nano $HOME/.epixd/validator.json
```
```
{
  "pubkey": ,
  "amount": "999000000000000000000apix",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
epixd tx staking create-validator $HOME/.epixd/validator.json \
--from wallet \
--chain-id epix_1916-1 \
--gas-prices="0.001aepix" \
--gas-adjustment=1.2 \
--gas=auto
```
```
 epixd tx staking edit-validator \
--new-moniker="Vinjan.Inc | RESTAKE" \
--identity="7C66E36EA2B71F68" \
--website="" \
--details="Staking Provider-IBC Relayer" \
--chain-id epix_1916-1 \
--from=wallet \
--gas-prices="0.002aepix" \
--gas-adjustment=1.5 \
--gas=auto
```
```
epixd tx distribution withdraw-rewards $(epixd keys show wallet --bech val -a) --commission --from wallet --chain-id epix_1916-1 --gas-adjustment=1.2 --gas-prices="0.001aepix" --gas=auto
```
```
epixd tx staking delegate $(epixd keys show wallet --bech val -a) 1000000000000000000aepix --from wallet --chain-id epix_1916-1 --gas-adjustment=1.2 --gas-prices="0.001aepix" --gas=auto
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
rm -rf epix
```

