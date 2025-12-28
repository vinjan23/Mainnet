### Binary
```
wget https://github.com/LumeraProtocol/lumera/releases/download/v1.8.5/lumera_v1.8.5_linux_amd64.tar.gz
tar xzvf lumera_v1.8.5_linux_amd64.tar.gz
chmod +x lumerad
mv lumerad $HOME/go/bin/
rm lumera_v1.8.5_linux_amd64.tar.gz
rm install.sh
mv libwasmvm.x86_64.so /usr/lib/
```
```
mkdir -p $HOME/.lumera/cosmovisor/genesis/bin
cp $HOME/go/bin/lumerad $HOME/.lumera/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.lumera/cosmovisor/genesis $HOME/.lumera/cosmovisor/current -f
sudo ln -s $HOME/.lumera/cosmovisor/current/bin/lumerad /usr/local/bin/lumerad -f
```
### Update
```
wget https://github.com/LumeraProtocol/lumera/releases/download/v1.9.0/lumera_v1.9.0_linux_amd64.tar.gz
tar xzvf lumera_v1.9.0_linux_amd64.tar.gz
chmod +x lumerad
rm lumera_v1.9.0_linux_amd64.tar.gz
rm install.sh
sudo mv libwasmvm.x86_64.so /usr/lib/
sudo ldconfig
```
```
mkdir -p $HOME/.lumera/cosmovisor/upgrades/v1.9.0/bin
mv lumerad $HOME/.lumera/cosmovisor/upgrades/v1.9.0/bin/
```
```
$HOME/.lumera/cosmovisor/upgrades/v1.9.0/bin/lumerad version --long | grep -e commit -e version
```
```
lumerad version  --long | grep -e version -e commit
```

### Init
```
lumerad init Vinjan.Inc --chain-id lumera-mainnet-1
```
### Genesis
```
wget -O $HOME/.lumera/config/genesis.json https://raw.githubusercontent.com/LumeraProtocol/lumera-networks/refs/heads/master/mainnet/genesis.json
```
### Port
```
PORT=177
sed -i -e "s%:26657%:${PORT}57%" $HOME/.lumera/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.lumera/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.lumera/config/app.toml
```

### Gas Price
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0ulume\"/" $HOME/.lumera/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "1000"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "11"|' \
$HOME/.lumera/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.lumera/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/lumerad.service > /dev/null << EOF
[Unit]
Description=lumera
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.lumera"
Environment="DAEMON_NAME=lumerad"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.lumera/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable lumerad
sudo systemctl restart lumerad
sudo journalctl -u lumerad -f -o cat
```
### Sync
```
lumerad status 2>&1 | jq .sync_info
```
### Wallet
```
lumerad keys add wallet --recover
```
### Balances
```
lumerad q bank balances $(lumerad keys show wallet -a)
```
### Validator
```
lumerad tendermint show-validator
```
```
nano $HOME/.lumera/validator.json
```
```
{
  "pubkey": ,
  "amount": "1000000ulume",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.01",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
lumerad tx staking create-validator $HOME/.lumera/validator.json \
--from wallet \
--chain-id lumera-mainnet-1 \
--gas-prices=0.025ulume \
--gas-adjustment=1.5 \
--gas=auto
```
```
lumerad tx staking edit-validator \
--new-moniker "Vinjan.Inc" \
--identity 7C66E36EA2B71F68 \
--from wallet \
--chain-id lumera-mainnet-1 \
--commission-rate=0.2 \
--gas-prices=0.025ulume \
--gas-adjustment=1.5 \
--gas=auto
```
```
lumerad tx distribution withdraw-rewards $(lumerad keys show wallet --bech val -a) --commission --from wallet --chain-id lumera-mainnet-1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.025ulume
```
```
lumerad tx staking delegate $(lumerad keys show wallet --bech val -a) 10000000ulume --from wallet --chain-id lumera-mainnet-1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.025ulume
```
```
lumerad tx gov vote 2 yes --from wallet --chain-id lumera-mainnet-1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.025ulume
```
```
echo $(lumerad tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.lumera/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Delete
```
sudo systemctl stop lumerad
sudo systemctl disable lumerad
sudo rm /etc/systemd/system/lumerad.service
sudo systemctl daemon-reload
rm -f $(which lumerad)
rm -rf .lumera
```

