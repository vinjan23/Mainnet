### Binary
```
cd $HOME
mkdir -p $HOME/.gnodi
wget https://github.com/gnodi-network/gnodi/releases/download/v1.0.1/gnodid-linux
chmod +x gnodid-linux
sudo mv gnodid-linux /usr/local/bin/gnodid
```
```
mkdir -p $HOME/.gnodi/cosmovisor/genesis/bin
cp /usr/local/bin/gnodid $HOME/.gnodi/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.gnodi/cosmovisor/genesis $HOME/.gnodi/cosmovisor/current -f
sudo ln -s $HOME/.gnodi/cosmovisor/current/bin/gnodid /usr/local/bin/gnodid -f
```
```
gnodid version --long | grep -e commit -e version
```
```
wget https://github.com/gnodi-network/gnodi/releases/download/v2.0.2/gnodid-linux
chmod +x gnodid-linux
sudo mv gnodid-linux /usr/local/bin/gnodid
```
```
mkdir -p $HOME/.gnodi/cosmovisor/upgrades/evm-upgrade/bin
cp /usr/local/bin/gnodid $HOME/.gnodi/cosmovisor/upgrades/evm-upgrade/bin/
```
```
cd $HOME
git clone https://github.com/gnodi-network/gnodi.git
cd gnodi
git checkout v2.0.0
make install
```
```
mkdir -p $HOME/.gnodi/cosmovisor/upgrades/evm-upgrade/bin
cp $HOME/go/bin/gnodid $HOME/.gnodi/cosmovisor/upgrades/evm-upgrade/bin/
```
```
$HOME/.gnodi/cosmovisor/upgrades/evm-upgrade/bin/gnodid version --long | grep -e commit -e version
```

### Init
```
gnodid init Vinjan.Inc --chain-id gnodi
```
### Genesis
```
wget -O $HOME/.gnodi/config/genesis.json https://raw.githubusercontent.com/gnodi-network/genesis-mainnet/refs/heads/main/genesis.json
```
### Peer
```
peers="c0aad4afe82f4e12f931860e7877787d356f17de@peer-gnodi.vinjan-inc.com:15556"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.gnodi/config/config.toml
```
### Port
```
PORT=155
sed -i -e "s%:26657%:${PORT}57%" $HOME/.gnodi/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.gnodi/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.gnodi/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.gnodi/config/app.toml
```
### Gas
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.25uGNOD\"/" $HOME/.gnodi/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.gnodi/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/gnodid.service > /dev/null << EOF
[Unit]
Description=gnodi
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.gnodi"
Environment="DAEMON_NAME=gnodid"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.gnodi/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable gnodid
sudo systemctl restart gnodid
sudo journalctl -u gnodid -f -o cat
```
```
gnodid status 2>&1 | jq .sync_info
```
```
gnodid keys add wallet
```
```
gnodid q bank balances $(gnodid keys show wallet -a)
```
```
gnodid comet show-validator
```
```
nano $HOME/.gnodi/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"R8/G8u1YaelVBkqhefIcy4kebKHx2DzXPpNR3F0d9IQ="},
  "amount": "100000000uGNOD",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer | Telegram : @vinjan",
  "commission-rate": "0.05",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
gnodid tx staking create-validator $HOME/.gnodi/validator.json \
--from wallet \
--chain-id gnodi \
--gas-prices="0.25uGNOD" \
--gas-adjustment=1.5 \
--gas=auto
```
### Unjail
```
gnodid tx slashing unjail --from wallet --chain-id gnodi --gas-adjustment=1.5 --gas=auto --gas-prices="0.25uGNOD"
```
### WD
```
gnodid tx distribution withdraw-rewards $(gnodid keys show wallet --bech val -a) --from wallet --chain-id gnodi --gas-adjustment=1.5 --gas=auto --gas-prices="0.25uGNOD"
```
### Delegate
```
gnodid tx staking delegate $(gnodid keys show wallet --bech val -a) 1000000uGNOD --from wallet --chain-id gnodi --gas-adjustment=1.5 --gas=auto --gas-prices="0.25uGNOD"
```

```
echo $(gnodid tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.gnodi/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Delete
```
sudo systemctl stop gnodid
sudo systemctl disable gnodid
sudo rm /etc/systemd/system/gnodid.service
sudo systemctl daemon-reload
rm -rf $(which gnodid)
rm -rf .gnodi
```
