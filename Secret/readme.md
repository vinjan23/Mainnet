###
```
cd $HOME
rm -rf secretnetwork_1.23.3_mainnet_goleveldb_amd64_ubuntu-24.04.deb
wget wget https://github.com/scrtlabs/SecretNetwork/releases/download/v1.23.3/secretnetwork_1.23.3_mainnet_goleveldb_amd64_ubuntu-22.04.deb
sudo apt install -y ./secretnetwork_1.23.3_mainnet_goleveldb_amd64_ubuntu-22.04.deb

```
```
mkdir -p $HOME/.secretd/cosmovisor/genesis/bin
cp $HOME/go/bin/secretd $HOME/.secretd/cosmovisor/genesis/bin
```
```
sudo ln -s $HOME/.secretd/cosmovisor/genesis $HOME/.secretd/cosmovisor/current -f
sudo ln -s $HOME/.secretd/cosmovisor/current/bin/secretd /usr/local/bin/secretd -f
```
### 
```
secretd init Vinjan.Inc --chain-id secret-4
```
```
wget -O $HOME/.secretd/config/genesis.json https://files.nodeshub.online/mainnet/secret/genesis.json
```
```
wget -O $HOME/.secretd/config/addrbook.json https://files.nodeshub.online/mainnet/secret/addrbook.json
```
### 
```
PORT=143
sed -i -e "s%:26657%:${PORT}57%" $HOME/.secretd/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.secretd/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.secretd/config/app.toml
```
###
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.00125uscrt"|g' $HOME/.secretd/config/app.toml
```
###
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.secretd/config/app.toml
```
### 
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.secretd/config/config.toml
```
### 
```
sudo tee /etc/systemd/system/secretd.service > /dev/null << EOF
[Unit]
Description=secret
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
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.secretd/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
###
```
sudo systemctl daemon-reload
sudo systemctl enable secretd
sudo systemctl restart secretd
sudo journalctl -u secretd -f -o cat
```
```
secretd status 2>&1 | jq .sync_info
```
```
secretd q bank balances $(secretd keys show wallet -a)
```
```
secretd comet show-validator
```
```
nano $HOME/.secretd/validator.json
```
```
{
  "pubkey": ,
  "amount": "17000000uscrt",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.02",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
secretd tx staking create-validator $HOME/.secretd/validator.json \
--from wallet \
--chain-id secret-4 \
--gas-prices="0.001uscrt" \
--gas-adjustment=1.2 \
--gas=auto
```
