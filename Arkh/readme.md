### Update
```
sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### GO
```
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
### Build
```
cd $HOME
rm -rf arkh-blockchain
git clone https://github.com/vincadian/arkh-blockchain
cd arkh-blockchain
git checkout v2.0.0
go build -o arkhd ./cmd/arkhd
```
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
mkdir -p $HOME/.arkh/cosmovisor/genesis/bin
mv arkhd $HOME/.arkh/cosmovisor/genesis/bin/
ln -s $HOME/.arkh/cosmovisor/genesis $HOME/.arkh/cosmovisor/current
sudo ln -s $HOME/.arkh/cosmovisor/current/bin/arkhd /usr/bin/arkhd
```
### Init
```
arkhd init <MONIKER> --chain-id arkh
arkhd config chain-id arkh
arkhd config keyring-backend file
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/vincadian/arkh-blockchain/master/genesis/genesis.json > $HOME/.arkh/config/genesis.json
```
### Addrbook
```
wget -O $HOME/.arkh/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/Arkh/addrbook.json"
```

### Seed
```
sed -i -e "s|^seeds *=.*|seeds = \"808f01d4a7507bf7478027a08d95c575e1b5fa3c@asc-dataseed.arkhadian.com:26656 \"|" $HOME/.arkh/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.arkh/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.arkh/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025arkh\"/" $HOME/.arkh/config/app.toml
```
### PORT
```
PORT=45
arkhd config node tcp://localhost:${PORT}657
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.arkh/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.arkh/config/app.toml
```
### Prunning
```
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="19"
sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.arkh/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.arkh/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.arkh/config/app.toml
```
### Create Service
```
sudo tee /etc/systemd/system/arkhd.service > /dev/null << EOF
[Unit]
Description=arkhadian node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.arkh"
Environment="DAEMON_NAME=arkhd"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable arkhd
sudo systemctl restart arkhd
sudo journalctl -fu arkhd -o cat
```
### Sync Info
```
arkhd status 2>&1 | jq .SyncInfo
```
### Log
```
journalctl -u arkhd -f -o cat
```
### Create Wallet
```
arkhd keys add wallet
```
### Recover
```
arkhd keys add wallet --recover
```
### List 
```
arkhd keys list
```
### Balances
```
arkhd q bank balances arkh1caclqqep2jprjn0evwyt3jkn6q3zxx4ckkguef
```
### Create Validator
```
arkhd tx staking create-validator \
--amount=30000000arkh \
--pubkey=$(arkhd tendermint show-validator) \
--moniker="vinjan" \
--identity=7C66E36EA2B71F68 \
--website=https://nodes.vinjan.xyz \
--details="https://explorer.vinjan.xyz" \
--chain-id=arkh \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallt \
--gas-prices=0.1arkh \
--gas-adjustment=1.5 \
--gas=auto \
-y
```
### Edit
```
arkhd tx staking edit-validator \
--new-moniker=vinjan \
 --identity=7C66E36EA2B71F68 \
 --website=nodes.vinjan.xyz \
 --details=satsetsatseterror \
 --chain-id=arkh \
 --from=wallt \
 --fees 5000arkh 
 -y
``` 
### Unjail
```
arkhd tx slashing unjail --from <wallet> --chain-id --chain-id arkh --fees 5000arkh -y
```

### WD All
```
arkhd tx distribution withdraw-all-rewards --from wallt --chain-id arkh --fees 5000arkh  -y
```

### WD with commission
```
arkhd tx distribution withdraw-rewards $(arkhd keys show wallt --bech val -a) --commission --from wallt --chain-id arkh --fees 5000arkh  -y
```
### Delegate
```
arkhd tx staking redelegate $(arkhd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 1000000arkh --from wallet --chain-id arkh  --fees 5000arkh  -y
```

### Transfer
```
arkhd tx bank send wallet <TO_WALLET_ADDRESS> 1000000arkh --from wallet --chain-id arkh
```

### Unbond
```
arkhd tx staking unbond $(arkhd keys show wallet --bech val -a) 1000000arkh --from wallet --chain-id arkh --fees 5000arkh  -y
```

### Check Reward
```
arkhd query distribution rewards $(arkhd keys show wallt -a) $(arkhd keys show wallt --bech val -a)
```
### Check Match Validator
```
[[ $(arkhd q staking validator $(arkhd keys show <Wallet_Name> --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(arkhd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Delete
```
sudo systemctl stop arkhd && \
sudo systemctl disable arkhd && \
rm /etc/systemd/system/arkhd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .arkh && \
rm -rf $(which arkhd)
```

 



