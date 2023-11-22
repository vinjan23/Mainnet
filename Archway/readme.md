### Package
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### GO
```
ver="1.20.6"
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
git clone https://github.com/archway-network/archway.git
cd archway
git checkout v4.0.2
make install
```

### Init
```
MONIKER=
```
```
archwayd init $MONIKER --chain-id archway-1
archwayd config chain-id archway-1
archwayd config keyring-backend file
```

### Port
```
PORT=34
archwayd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.archway/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.archway/config/app.toml
```

### Genesis
```
curl -Ls https://ss.archway.nodestake.top/genesis.json > $HOME/.archway/config/genesis.json
```
### Addrbook
```
wget -O $HOME/.archway/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/Archway/addrbook.json"
```

### Seed Peer Gas
```
SEEDS="3ba7bf08f00e228026177e9cdc027f6ef6eb2b39@35.232.234.58:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.archway/config/config.toml
PEERS="47dc5221ee5e1bdd1a8d51093be5d25c4c0c8e95@51.195.6.227:26662,bd55b5f6d58013f2b14453de63510a06e5949b14@167.235.180.97:11556,b96b188c049814c0c848d285ebbfa5af77396387@65.108.238.219:11556,996a4e60bea02401787178cac264fddf23301921@65.109.20.54:11556,dec4f5b15f44dd1c1a35084e4d2da7e05fa7a9da@95.216.46.125:31656,f1b210360e2df8242cbbd9a54662abfd1d6a9faf@136.243.67.189:11556,3ba7bf08f00e228026177e9cdc027f6ef6eb2b39@35.232.234.58:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.archway/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"1000000000000aarch\"|" $HOME/.archway/config/app.toml
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.archway/config/app.toml
```

### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.archway/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/archwayd.service << EOF
[Unit]
Description=archway-mainnet
After=network-online.target
#
[Service]
User=$USER
ExecStart=$(which archwayd) start
RestartSec=3
Restart=on-failure
LimitNOFILE=65535
#
[Install]
WantedBy=multi-user.target
EOF
```

### Star
```
sudo systemctl daemon-reload
sudo systemctl enable archwayd
sudo systemctl restart archwayd
sudo journalctl -u archwayd -f -o cat
```

### Sync
```
archwayd status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u archwayd -f -o cat
```

### Wallet
```
archwayd keys add wallet --recover
```

### Balance
```
archwayd q bank balances $(archwayd keys show wallet -a)
```

### Validator
```
archwayd tx staking create-validator \
--amount 1000000000000000000aarch \
--pubkey $(archwayd tendermint show-validator) \
--moniker "vinjan" \
--identity "7C66E36EA2B71F68" \
--details "🎉Proffesional Stake & Node Validator🎉" \
--website "https://service.vinjan.xyz" \
--chain-id archway-1 \
--commission-rate 0.1 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--from wallet \
--gas-adjustment 1.4 \
--fees ‎180000000000000000aarch \
-y
```
### Edit
```
archwayd tx staking edit-validator \
--new-moniker="" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL"
--chain-id archway-1 \
--from=<wallet> \
--gas-adjustment=1.4 \
--gas auto \
--fees ‎‎180000000000000000aarch \
-y
```


### Unjail
```
archwayd tx slashing unjail --from wallet --chain-id archway-1 --gas-adjustment=1.4 --fees ‎180000000000000000aarch -y
```
Check Jailed Reason
```
archwayd query slashing signing-info $(archwayd tendermint show-validator)
```
### Delegate
```
archwayd tx staking delegate $(archwayd keys show wallet --bech val -a) 1000000000000000000aarch --from wallet --chain-id archway-1 --gas-adjustment 1.4 --gas auto --gas-prices 1000000000000aarch -y
```
### WD All
```
archwayd tx distribution withdraw-rewards $(archwayd keys show wallet --bech val -a) --commission --from wallet --chain-id archway-1 --gas-adjustment="1.4" --gas auto --gas-prices 1000000000000aarch -y
```
### WD with commission
```
archwayd tx distribution withdraw-rewards $(archwayd keys show wallet --bech val -a) --commission --from wallet --chain-id archway-1 --gas-adjustment="1.4" --gas auto --gas-prices 1000000000000aarch -y
```
### Transfer
```
archwayd tx bank send wallet <TO_WALLET_ADDRESS> 1000000000000000000aarch --from wallet --chain-id archway-1 --gas-adjustment="1.4" --gas auto --gas-prices 1000000000000aarch -y
```
### Vote
```
archwayd tx gov vote 1 yes --from wallet --chain-id archway-1 --gas-adjustment="1.4" --gas auto --gas-prices 1000000000000aarch -y
```
### Validator Info
```
archwayd status 2>&1 | jq .ValidatorInfo
```
### Check Validator Matchs
```
[[ $(archwayd q staking validator $(archwayd keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(archwayd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Own Peer
```
echo $(archwayd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.archway/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
### Connected Peer
```
curl -sS http://localhost:34657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Stop
```
sudo systemctl stop archwayd
```

### Restart
```
sudo systemctl restart archwayd
```

### Delete
```
sudo systemctl stop archwayd
sudo systemctl disable archwayd
sudo rm /etc/systemd/system/archwayd.service
sudo systemctl daemon-reload
rm -f $(which archwayd)
rm -rf .archway
rm -rf archway
```

