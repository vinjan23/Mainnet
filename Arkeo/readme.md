### Binary
```
cd $HOME
rm -rf arkeo
git clone https://github.com/arkeonetwork/arkeo.git
cd arkeo
git checkout v1.0.13
make install
```

### Update
```
cd $HOME
rm -rf arkeo
git clone https://github.com/arkeonetwork/arkeo.git
cd arkeo
git checkout v1.0.14
make install
```
```
arkeod version --long | grep -e commit -e version
```
### Init
```
arkeod init Vinjan.Inc --chain-id arkeo-main-v1
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:24657\"%" $HOME/.arkeo/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:24658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:24657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:24060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:24656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":24660\"%" $HOME/.arkeo/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:24317\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:24090\"%" $HOME/.arkeo/config/app.toml
```
### Genesis
```
curl -L https://snapshot-t.vinjan.xyz/arkeo/genesis.json > $HOME/.arkeo/config/genesis.json
```
### Addrbook
```
curl -L https://snapshot-t.vinjan.xyz/arkeo/addrbook.json > $HOME/.arkeo/config/addrbook.json
```
### Seed
```
seeds="4d2c67a1d732679826b2f71c833e94b3718c2b50@seed2.arkeo.network:26656,416bd4379fa4fa3e76e59e4415396f727463142e@seed.arkeo.network:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.arkeo/config/config.toml
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.01uarkeo"|' $HOME/.arkeo/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.arkeo/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.arkeo/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/arkeod.service > /dev/null <<EOF
[Unit]
Description=arkeo
After=network-online.target

[Service]
User=$USER
ExecStart=$(which arkeod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable arkeod
```
```
sudo systemctl restart arkeod
```
```
sudo journalctl -u arkeod -f -o cat
```
### Sync
```
arkeod status 2>&1 | jq .sync_info
```
### Wallet
```
arkeod keys add wallet
```
### Balances
```
arkeod q bank balances $(arkeod keys show wallet -a)
```
### Validator
```
arkeod tendermint show-validator
```
```
nano /root/.arkeo/validator.json
```
```
{
  "pubkey": $(arkeod tendermint show-validator),
  "amount": "1800000000uarkeo",
  "moniker": "Low Fees | Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.01",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
```
```
arkeod tx staking create-validator $HOME/.arkeo/validator.json \
--from wallet \
--chain-id arkeo-main-v1 \
--gas-prices=0.01uarkeo \
--gas-adjustment=1.5 \
--gas=auto
```
### Delegate
```
arkeod tx staking delegate $(arkeod keys show wallet --bech val -a) 1000000uarkeo --from wallet --chain-id arkeo-main-v1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.01uarkeo
```
### WD
```
arkeod tx distribution withdraw-rewards $(arkeod keys show wallet --bech val -a) --commission --from wallet --chain-id arkeo-main-v1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.01uarkeo
```
### Own Peer
```
echo $(arkeod tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.arkeo/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
###Vote
```
arkeod tx staking delegate $(arkeod keys show wallet --bech val -a) 1000000uarkeo --from wallet --chain-id arkeo-main-v1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.01uarkeo
```
### Move
```
sudo rm /var/www/snapshot-t/arkeo/addrbook.json && cp $HOME/.arkeo/config/addrbook.json /var/www/snapshot-t/arkeo/addrbook.json
```

### Delete
```
sudo systemctl stop arkeod
sudo systemctl disable arkeod
sudo rm /etc/systemd/system/arkeod.service
sudo systemctl daemon-reload
rm -f $(which arkeod)
rm -rf .arkeo
rm -rf arkeo
```







