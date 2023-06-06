### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### GO
```
ver="1.20.4"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### Binary
```
cd $HOME
git clone https://github.com/notional-labs/composable-centauri.git
cd composable-centauri
git checkout v2.3.5
make install
```

### Init
```
MONIKER=
```
```
banksyd init $MONIKER --chain-id centauri-1
banksyd config chain-id centauri-1
banksyd config keyring-backend file
```

### Genesis
```
wget -O ~/.banksy/config/genesis.json https://raw.githubusercontent.com/notional-labs/composable-networks/main/mainnet/genesis.json
```

### Seed & Peer & Gas
```
peers="4cb008db9c8ae2eb5c751006b977d6910e990c5d@65.108.71.163:2630,63559b939442512ed82d2ded46d02ab1021ea29a@95.214.55.138:53656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.banksy/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0ppica\"|" $HOME/.banksy/config/app.toml
SEEDS="c7f52f81ee1b1f7107fc78ca2de476c730e00be9@65.109.80.150:2635"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.banksy/config/config.toml
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.banksy/config/app.toml
```

### Service
```
sudo tee /etc/systemd/system/banksyd.service > /dev/null << EOF
[Unit]
Description=composable
After=network-online.target

[Service]
User=$USER
ExecStart=$(which banksyd) start
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
sudo systemctl enable banksyd
sudo systemctl restart banksyd
sudo journalctl -u banksyd -f -o cat
```

### Sync
```
banksyd status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u banksyd -f -o cat
```

### Balance
```
banksyd q bank balances $(banksyd keys show wallet -a)
```

### Wallet
```
banksyd keys add wallet
```
### Recover
```
banksyd keys add wallet --recover
```

### Validator
```
banksyd add-genesis-account wallet 50000000000000ppica
banksyd gentx wallet 50000000000000ppica \
--moniker="vinjan" \
--identity="7C66E36EA2B71F68" \
--details="🎉Proffesional Stake & Node Validator🎉" \
--website="https://service.vinjan.xyz" \
--security-contact="" \
--pubkey $(banksyd tendermint show-validator) \
--chain-id centauri-1
--commission-rate 0.1 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--from wallet \
--gas-adjustment 1.4 \
--gas auto \
--gas-prices 0ppica \
-y
```

### Unjail
```
banksyd tx slashing unjail --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0ppica -y
```
### Reason
```
banksyd query slashing signing-info $(banksyd tendermint show-validator)
```

### Delegate
```
banksyd tx staking delegate <TO_VALOPER_ADDRESS> 1000000ppica --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0ppica -y
```

### WD
```
banksyd tx distribution withdraw-all-rewards --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas 55000 --gas-prices 0ppica -y
```

### WD with commission
```
banksyd tx distribution withdraw-rewards $(banksyd keys show wallet --bech val -a) --commission --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0upica -y
```

### Check Match
```
[[ $(banksyd q staking validator $(banksyd keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(banksyd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Stop
```
sudo systemctl stop banksyd
```

### Restart
```
sudo systemctl restart banksyd
```

### Delete
```
sudo systemctl stop banksyd
sudo systemctl disable banksyd
sudo rm /etc/systemd/system/banksyd.service
sudo systemctl daemon-reload
rm -f $(which banksyd)
rm -rf $HOME/.banksy
rm -rf $HOME/composable-centauri
```
