```
wget https://github.com/Bookings-cpu/nexarail/releases/download/v0.1.0-rc1-validator-recovery-hotfix/nexaraild-linux-amd64
chmod +x nexaraild-linux-amd64
mv nexaraild-linux-amd64 $HOME/go/bin/nexaraild
```
```
wget https://github.com/Bookings-cpu/nexarail/releases/download/mainnet-genesis-nexarail-mainnet-2/nexaraild-linux-amd64 -O $HOME/go/bin/nexaraild
chmod +x $HOME/go/bin/nexaraild
cp $HOME/go/bin/nexaraild /usr/local/bin/
```
```
nexaraild init vinjan --chain-id nexarail-mainnet-2
```

```
nexaraild version
```
```
curl -L https://github.com/Bookings-cpu/nexarail/releases/download/mainnet-genesis-nexarail-mainnet-2/genesis.json > $HOME/.nexarail/config/genesis.json
```

```
sed -i -e "s/^chain-id *=.*/chain-id = \"nexarail-mainnet-2\"/;" ~/.nexarail/config/client.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001unxrl\"/;" ~/.nexarail/config/app.toml
```
```
PORT=169
sed -i -e "s%:26657%:${PORT}57%" $HOME/.nexarail/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.nexarail/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.nexarail/config/app.toml
```
```
peers="1af9139d59677cc42ff2924c89f9cf9e0c980246@5.161.85.160:26656,d91372d5918d870c7861a2eb3e
99b90d7c5882ca@5.161.103.203:26656,8776e496483fefbbc4dc17749f5ec80ab121fe2c@5.161.99.76
:26656,45668d1ae375f39fce47dfa96e76db7946da7188@5.161.94.47:26656,bbd2b07264da053541128
a0677540bc95bf415c6@5.161.72.48:26656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.nexarail/config/config.toml
```

```
pruning="custom"
pruning_keep_recent="100"
pruning_interval="20"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nexarail/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nexarail/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nexarail/config/app.toml
```
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nexarail/config/config.toml
```
```
sudo tee /etc/systemd/system/nexaraild.service > /dev/null << EOF
[Unit]
Description=nexarail
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.nexarail"
Environment="DAEMON_NAME=nexaraild"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.nexarail/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable nexaraild
sudo systemctl restart nexaraild
sudo journalctl -u nexaraild -f -o cat
```
```
nexaraild status 2>&1 | jq .SyncInfo
```
```
nexaraild keys add wallet
```
```
nexaraild q bank balances $(nexaraild keys show wallet -a)
```
```
nexaraild tx staking create-validator \
--amount=500000000unxrl \
--pubkey="$(nexaraild tendermint show-validator)" \
--moniker="Vinjan.Inc" \
--chain-id=nexarail-mainnet-1 \
--identity="7C66E36EA2B71F68" \
--details="Staking Provider-IBC Relayer" \
--from=wallet \
--commission-rate="0.10" \
--commission-max-rate="1" \
--commission-max-change-rate="1" \
--min-self-delegation="1" \
--gas=auto \
--gas-adjustment=1.4 \
--gas-prices=0.025unxrl \
--node tcp://localhost:16957
```
```  
nexaraild tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--details="Staking Provider-IBC Relayer" \
--chain-id=nexarail-mainnet-1 \
--from=wallet \
--commission-rate="1" \
--gas-adjustment=1.4 \
--gas-prices="0.025unxrl" \
--gas=auto 
```
```
nexaraild tx slashing unjail --from wallet --chain-id nexarail-mainnet-1 --gas-adjustment=1.4 --gas-prices=0.025unxrl --gas auto 
```
```
nexaraild tx distribution withdraw-rewards $(nexaraild keys show wallet --bech val -a) --commission --from wallet --chain-id nexarail-mainnet-1 --gas-adjustment=1.4 --gas-prices=0.025unxrl --gas auto 
```
```
nexaraild tx staking delegate $(nexaraild keys show wallet --bech val -a) 1000000unxrl --from wallet --chain-id nexarail-mainnet-1 --gas-adjustment=1.4 --gas-prices=0.025unxrl --gas auto 
```
```
echo $(nexaraild tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.nexarail/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
```
nexaraild tendermint show-address
```
```
nexaraild tx gov vote 3 yes --from wallet --chain-id nexarail-mainnet-1 --gas-adjustment=1.4 --gas-prices=0.05unxrl --gas auto
```
```
sudo systemctl stop nexaraild
sudo systemctl disable nexaraild
sudo rm /etc/systemd/system/nexaraild.service
sudo systemctl daemon-reload
rm -rf $(which nexaraild)
rm -rf .nexarail
```

