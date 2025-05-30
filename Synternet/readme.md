### Bianry
```
curl -LO https://github.com/Synternet/synternet-chain-releases/releases/download/v0.21.0/syntd-linux-amd64-v0.21.0
mv syntd-linux-amd64-v0.21.0 ~/go/bin/syntd
chmod u+x ~/go/bin/syntd
```
### Init
```
syntd init Vinjan.inc --chain-id synternet-1
```

### Genesis
```
wget -O $HOME/.amber/config/genesis.json https://raw.githubusercontent.com/Synternet/synternet-chain-releases/refs/heads/main/networks/mainnet/genesis.json
```

### Port
```
PORT=31
syntd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.amber/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%" $HOME/.amber/config/app.toml
```
### Config
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01usynt\"/" $HOME/.amber/config/app.toml
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.amber/config/config.toml
seeds="2eed7e175d204680af243e008e21950f81b8d455@34.89.206.173:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.amber/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.amber/config/config.toml
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.amber/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.amber/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/syntd.service > /dev/null <<EOF
[Unit]
Description=Synternet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which syntd) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable syntd
sudo systemctl restart syntd
sudo journalctl -u syntd -f -o cat
```
### Sync
```
syntd  status 2>&1 | jq .SyncInfo
```
### Wallet
```
syntd  keys add wallet
```
### Balances
```
syntd q bank balances $(syntd keys show wallet -a)
```

### Validator
```
syntd tx staking create-validator \
--amount=17000000usynt \
--pubkey=$(syntd tendermint show-validator) \
--moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Staking Provider-IBC Relayer" \
--chain-id=synternet-1 \
--commission-rate="0.05" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation 1 \
--gas="auto" \
--gas-adjustment="1.3" \
--gas-prices="0.01usynt" \
--from=wallet
```
```
syntd tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Staking Provider-IBC Relayer" \
--chain-id=synternet-1 \
--commission-rate="0.03" \
--gas="auto" \
--gas-adjustment="1.3" \
--gas-prices="0.01usynt" \
--from=wallet
```
### Unjail
```
syntd tx slashing unjail --from wallet --chain-id synternet-1 --gas-adjustment=1.3 --gas-prices=0.01usynt --gas=auto
```

### Wd
```
syntd tx distribution withdraw-rewards $(syntd keys show wallet --bech val -a) --commission --from wallet --chain-id synternet-1 --gas-adjustment=1.3 --gas-prices=0.01usynt --gas=auto
```
### Delegate
```
syntd tx staking delegate $(syntd keys show wallet --bech val -a) 1000000usynt --from wallet ---chain-id synternet-1 --gas-adjustment=1.3 --gas-prices=0.01usynt --gas=auto
```

### Delete
```
sudo systemctl stop syntd
sudo systemctl disable syntd
sudo rm /etc/systemd/system/syntd.service
sudo systemctl daemon-reload
rm -f $(which syntd)
rm -rf .amber
rm -rf synternet
```







