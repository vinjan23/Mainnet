### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install git build-essential curl jq libclang-dev clang cmake gcc -y
```

### GO
```
ver="1.20.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### Bianry
```
cd $HOME
git clone https://github.com/terpnetwork/terp-core.git
cd terp-core
git checkout v4.2.0
make install
```
### Update
```
cd terp-core 
git fetch --tags
git checkout v3-pigeonfall
make install
```
```
cd terp-core
git fetch --all
git checkout v4.1.1
make install
```

### Moniker
```
MONIKER=
```

### Init
```
terpd init $MONIKER --chain-id morocco-1
terpd config chain-id morocco-1
terpd config keyring-backend file
```

### Custom Port
```
PORT=46
terpd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.terp/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.terp/config/app.toml
```

### Genesis
```
curl -L https://snapshots.nodejumper.io/terpnetwork/genesis.json > $HOME/.terp/config/genesis.json
```

### Addrbook
```
wget -O $HOME/.terp/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/main/Terp/addrbook.json
```

### Seed & Peers & Gas
```
SEEDS="c71e63b5da517984d55d36d00dc0dc2413d0ce03@seed.terp.network:26656"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.terp/config/config.toml
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.000uterp"|g' $HOME/.terp/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.terp/config/config.toml
```

### Prunning
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.terp/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.terp/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.terp/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.terp/config/app.toml
```
### Indexer Null
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.terp/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/terpd.service > /dev/null << EOF
[Unit]
Description=TerpNetwork Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which terpd) start
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
sudo systemctl enable terpd
sudo systemctl restart terpd
sudo journalctl -u terpd -f -o cat
```

### Sync
```
terpd status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u terpd -f -o cat
```

### Wallet
```
terpd keys add wallet --recover
```

### Balances
```
terpd q bank balances 
```

### Validator
```
terpd tx staking create-validator \
--amount="1000000"uterp \
--pubkey=$(terpd tendermint show-validator) \
--moniker="vinjan" \
--details="" \
--website="https://nodes.vinjan.xyz" \
--identity "7C66E36EA2B71F68" \
--chain-id="morocco-1" \
--commission-rate="0.04" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.1" \
--min-self-delegation="1" \
--from=wallet \
--gas auto \
--gas-adjustment 1.3 \
--fees 70000uthiol
```

### Unjail
```
terpd tx slashing unjail --from wallet --chain-id morocco-1 --gas-prices 0.05uthiol --gas-adjustment 1.3 --gas auto -y
```

### Withdraw All
```
terpd tx distribution withdraw-all-rewards --from wallet --chain-id morocco-1 --gas-prices 0.05uthiol --gas-adjustment="1.3" --gas auto -y
```

### Withdraw with comission
```
terpd tx distribution withdraw-rewards $(terpd keys show wallet --bech val -a) --commission --from wallet --chain-id morocco-1 --gas-prices 0.05uthiol --gas-adjustment="1.3" --gas auto -y
```

### Delegate
```
terpd tx staking delegate $(terpd keys show wallet --bech val -a) 1000000uterp --from wallet --chain-id morocco-1 --gas-prices 0.05uthiol --gas-adjustment="1.3" --gas auto -y
```
### Vote
```
terpd tx gov vote 10 yes --from wallet --chain-id morocco-1 --gas-prices 0.05uthiol --gas-adjustment 1.5 --gas auto -y
```

### Stop
```
sudo systemctl stop terpd
```

### Restart
```
sudo systemctl restart terpd
```

### Check Match
```
[[ $(terpd q staking validator $(terpd keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(terpd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Delete
```
sudo systemctl stop terpd && \
sudo systemctl disable terpd && \
rm /etc/systemd/system/terpd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf terp && \
rm -rf .terpd && \
rm -rf $(which terpd)
```

`542F7DD38308B9DB91947FBEBA6018B29468C30C3992CF35005D2311C167EE8E`
`E5621929BB4059A3FA7242F8D7CD1023AA272EF9E87434065014F108DFB374B6`

