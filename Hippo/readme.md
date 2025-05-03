### Binary
```
cd $HOME
git clone https://github.com/hippocrat-dao/hippo-protocol hippo
cd hippo
git checkout main
make install
```
```
mkdir -p $HOME/.hippo/cosmovisor/genesis/bin
cp $HOME/go/bin/hippod $HOME/.hippo/cosmovisor/genesis/bin
```
```
ln -s $HOME/.hippo/cosmovisor/genesis $HOME/.hippo/cosmovisor/current -f
sudo ln -s $HOME/.hippo/cosmovisor/current/bin/hippod /usr/local/bin/hippod -f
```
### Init
```
hippod init Vinjan.Inc --chain-id hippo-protocol-1
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:10657\"%" $HOME/.hippo/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:10658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:10657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:10060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:10656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":10660\"%" $HOME/.hippo/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:10317\"%; s%^address = \"localhost:9090\"%address = \"localhost:10090\"%" $HOME/.hippo/config/app.toml
```
### Genesis
```
curl -L https://snapshot.vinjan.xyz/hippo/genesis.json > $HOME/.hippo/config/genesis.json
```
### Addrbook
```
curl -L https://snapshot.vinjan.xyz./hippo/addrbook.json > $HOME/.hippo/config/addrbook.json
```
### Gas
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"5000000000000ahp\"/;" ~/.hippo/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.hippo/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.hippo/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/hippod.service > /dev/null << EOF
[Unit]
Description=hippo
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.hippo"
Environment="DAEMON_NAME=hippod"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.hippo/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable hippod
```
```
sudo systemctl restart hippod
sudo journalctl -u hippod -f -o cat
```
### Sync
```
hippod status 2>&1 | jq .sync_info
```
### Wallet
```
hippod keys add wallet
```
### Balances
```
hippod q bank balances $(hippod keys show wallet -a)
```
### Valiadator
```
hippod tendermint show-validator
```
```
nano /root/.hippo/validator.json
```
```
{
  "pubkey": ,
  "amount": "1800000000ahp",
  "moniker": "Low Fees | Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.02",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
```
```
hippod tx staking create-validator $HOME/.hippo/validator.json \
--from wallet \
--chain-id hippo-protocol-1 \
--gas-prices=5000000000000ahp \
--gas-adjustment=1.2 \
--gas=auto
```
### Edit
```
hippod tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--commission-rate="0.1" \
--from=wallet \
--chain-id hippo-protocol-1 \
--gas-prices=5000000000000ahp \
--gas-adjustment=1.2 \
--gas=auto
```
### Delegate
```
hippod tx staking delegate $(hippod keys show wallet --bech val -a) 1000000ahp --from wallet --chain-id hippo-protocol-1 --gas-adjustment=1.2 --gas-prices=5000000000000ahp --gas=auto
```
### WD Comission
```
hippod tx distribution withdraw-rewards $(hippod keys show wallet --bech val -a) --commission --from wallet --chain-id hippo-protocol-1 --gas-adjustment=1.2 --gas-prices=5000000000000ahp --gas=auto
```
### Own peer
```
echo $(hippod tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.hippo/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Delete
```
sudo systemctl stop hippod
sudo systemctl disable hippod
sudo rm /etc/systemd/system/hippod.service
sudo systemctl daemon-reload
rm -f $(which hippod)
rm -rf .hippo
rm -rf hippo
```

