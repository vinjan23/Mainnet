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
### Update
```
cd $HOME/composable-centauri
git pull
git checkout v3.1.0
make install
```
### Update
```
cd $HOME/composable-centauri
git pull
git checkout v3.1.1
make install
```

### Init
```
MONIKER=
```
```
centaurid init $MONIKER --chain-id centauri-1
centaurid config chain-id centauri-1
centaurid config keyring-backend file
```
### Port
```
PORT=23
centaurid config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.banksy/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.banksy/config/app.toml
```

### Genesis
```
wget -O ~/.banksy/config/genesis.json https://raw.githubusercontent.com/notional-labs/composable-networks/main/mainnet/genesis.json
```

### Addrbook
```
wget -O ~/.banksy/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/main/Composable/addrbook.json
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
tee /etc/systemd/system/centaurid.service > /dev/null <<EOF
[Unit]
Description=centaurid
After=network-online.target

[Service]
User=$USER
ExecStart=$(which centaurid) start
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
sudo systemctl enable centaurid
sudo systemctl restart centaurid
sudo journalctl -u centaurid -f -o cat
```

### Sync
```
centaurid status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u centaurid -f -o cat
```

### Balance
```
centaurid q bank balances $(centaurid keys show wallet -a)
```

### Wallet
```
centaurid keys add wallet
```
### Recover
```
centaurid keys add wallet --recover
```

### Validator
```
centaurid tx staking create-validator \
--amount 1000000ppica \
--moniker="vinjan" \
--identity="7C66E36EA2B71F68" \
--details="🎉Proffesional Stake & Node Validator🎉" \
--website="https://service.vinjan.xyz" \
--security-contact="" \
--pubkey $(centaurid tendermint show-validator) \
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
centaurid tx slashing unjail --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0ppica -y
```
### Reason
```
centaurid query slashing signing-info $(banksyd tendermint show-validator)
```

### Delegate
```
centaurid tx staking delegate <TO_VALOPER_ADDRESS> 1000000ppica --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0ppica -y
```

### WD
```
centaurid tx distribution withdraw-all-rewards --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas 55000 --gas-prices 0ppica -y
```

### WD with commission
```
centaurid tx distribution withdraw-rewards $(centaurid keys show wallet --bech val -a) --commission --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0ppica -y
```

### Check Match
```
[[ $(centaurid q staking validator $(centaurid keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(centaurid status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Vote
```
centaurid tx gov vote 3 yes --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices 0ppica -y
```

### Stop
```
sudo systemctl stop centaurid
```

### Restart
```
sudo systemctl restart centaurid
```

### Delete
```
sudo systemctl stop centaurid
sudo systemctl disable centaurid
sudo rm /etc/systemd/system/centaurid.service
sudo systemctl daemon-reload
rm -f $(which centaurid)
rm -rf $HOME/.banksy
rm -rf $HOME/composable-centauri
```
