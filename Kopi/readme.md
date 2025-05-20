### GO
```
ver="1.23.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### Wasm
```
rm /usr/lib/libwasmvm.x86_64.so
wget -P /usr/lib https://github.com/CosmWasm/wasmvm/releases/download/v2.1.4/libwasmvm.x86_64.so
sudo ldconfig
```

### Binary
```
cd $HOME
rm -rf kopi
git clone --quiet --depth 1 --branch v16.1 https://github.com/kopi-money/kopi.git
cd kopi
make install
```
```
cd $HOME
rm -rf kopi
git clone https://github.com/kopi-money/kopi.git
cd kopi
git checkout v20.2
make install
```
```
kopid version --long | grep -e commit -e version
```


### Init
```
kopid init Vinjan.Inc --chain-id luwak-1
```
### Genesis
```
wget -q https://data.kopi.money/genesis.json -O ~/.kopid/config/genesis.json
```
```
wget -O $HOME/.kopid/config/genesis.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Kopi/genesis.json
```
### Addrbook
```
wget -O $HOME/.kopid/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Kopi/addrbook.json
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:45657\"%" $HOME/.kopid/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:45658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:45657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:45060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:45656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":45660\"%" $HOME/.kopid/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:45317\"%; s%^address = \"localhost:9090\"%address = \"localhost:45090\"%" $HOME/.kopid/config/app.toml
```
### Seed
```
seeds="85919e3dcc7eec3b64bfdd87657c4fac307c9d23@65.109.34.145:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.kopid/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ukopi\"/;" ~/.kopid/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.kopid/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.kopid/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/kopid.service > /dev/null << EOF
[Unit]
Description=kopi
After=network-online.target
[Service]
User=$USER
ExecStart=$(which kopid) start
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
sudo systemctl enable kopid
```
```
sudo systemctl restart kopid
```
```
sudo journalctl -u kopid -f -o cat
```

### Sync
```
kopid status 2>&1 | jq .sync_info
```
### Wallet
```
kopid  keys add wallet --recover
```
### Balances
```
kopid  q bank balances $(kopid keys show wallet -a)
```
### Validator
```
kopid tendermint show-validator
```
```
nano /root/.kopid/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"V="},
  "amount": "100000000ukopi",
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
kopid tx staking create-validator $HOME/.kopid/validator.json \
--from wallet \
--chain-id luwak-1
```
### Edit
```
kopid tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--commission-rate="0.1" \
--chain-id=luwak-1 \
--from=wallet
```
### Unjail
```
kopid tx slashing unjail --from wallet --chain-id luwak-1 --gas auto --gas-adjustment=1.5 --gas=auto --gas-prices=0.001ukopi
```  
### Wd
```
kopid tx distribution withdraw-rewards $(kopid keys show wallet --bech val -a) --commission --from wallet --chain-id luwak-1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.001ukopi
```
### Delegate
```
kopid tx staking delegate $(kopid keys show wallet --bech val -a) 1000000ukopi --from wallet --chain-id luwak-1 --gas-adjustment=1.5 --gas=auto --gas-prices=0.001ukopi
```
### Vote
```
kopid tx gov vote 30 yes --from wallet --chain-id luwak-1 --fees 60000ukopi
```

### Delete
```
sudo systemctl stop kopid
sudo systemctl disable kopid
sudo rm /etc/systemd/system/kopid.service
sudo systemctl daemon-reload
rm -f $(which kopid)
rm -rf .kopid
rm -rf kopi
```


