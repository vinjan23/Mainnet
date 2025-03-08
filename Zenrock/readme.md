### Binary
```
cd $HOME
mkdir -p /root/go/bin/
wget https://snapshot.vinjan.xyz./zenrock/zenrockd
chmod +x zenrockd
mv zenrockd /root/go/bin/
```
### Update
```
cd $HOME
rm -rf zrchain
git clone https://github.com/Zenrock-Foundation/zrchain
cd zrchain
git checkout v5.16.18
make install
```
```
zenrockd version --long | grep -e version -e commit
```
`version: 5.5.0`
`commit: 1c5e92e50435c334cf814377254367392a4dfda5`
### Init
```
zenrockd init Vinjan.inc --chain-id diamond-1
```
```
zenrockd config set client chain-id diamond-1
```
### Genesis
```
curl -Ls https://snapshot.vinjan.xyz./zenrock/genesis.json > $HOME/.zrchain/config/genesis.json
```
### Addrbook
```
curl -Ls https://snapshot.vinjan.xyz./zenrock/addrbook.json > $HOME/.zrchain/config/addrbook.json
```

### Port 18
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:18657\"%" $HOME/.zrchain/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:18658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:18657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:18060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:18656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":18660\"%" $HOME/.zrchain/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:18317\"%; s%^address = \"localhost:9090\"%address = \"localhost:18090\"%" $HOME/.zrchain/config/app.toml
```
### Config
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01urock\"/" $HOME/.zrchain/config/app.toml
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.zrchain/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.zrchain/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.zrchain/config/config.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.zrchain/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.zrchain/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/zenrockd.service > /dev/null <<EOF
[Unit]
Description=Zenrock
After=network-online.target

[Service]
User=$USER
ExecStart=$(which zenrockd) start
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
sudo systemctl enable zenrockd
sudo systemctl restart zenrockd
sudo journalctl -u zenrockd -f -o cat
```
### Sync
```
zenrockd status 2>&1 | jq .sync_info
```
### Add Wallet
```
zenrockd keys add wallet
```
### Balances
```
zenrockd  q bank balances $(zenrockd keys show wallet -a)
```

### Create Validator
```
zenrockd tendermint show-validator
```
```
nano /root/.zrchain/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"...."},
  "amount": "100000000urock",
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
zenrockd tx validation create-validator $HOME/.zrchain/validator.json \
--from=wallet \
--chain-id=diamond-1 \
--gas-adjustment 1.5 \
--gas-prices 27urock \
--gas auto
```
### Wd Commission
```
zenrockd tx staking delegate $(zenrockd keys show wallet --bech val -a) 1000000urock --from wallet --chain-id diamond-1 --gas-adjustment 1.5 --gas-prices 27urock --gas auto
```
### Staking
```
zenrockd tx staking delegate $(zenrockd keys show wallet --bech val -a) 1000000urock --from wallet --chain-id  diamond-1 --gas-adjustment 1.5 --gas-prices 27urock --gas auto
```


### Delete
```
sudo systemctl stop zenrockd
sudo systemctl disable zenrockd
sudo rm /etc/systemd/system/zenrockd.service
sudo systemctl daemon-reload
rm -f $(which zenrockd)
rm -rf .zrchain
rm -rf zenrock
```







