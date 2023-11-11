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
git clone https://github.com/vincadian/arkh-blockchain.git
cd arkh-blockchain
git checkout v2.0.0
go install ./...
arkhd version
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
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.arkh/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.arkh/config/app.toml
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
### Indexer Null
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.arkh/config/config.toml
```

### Create Service
```
sudo tee /etc/systemd/system/arkhd.service > /dev/null <<EOF
[Unit]
Description=arkhd Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which arkhd) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable arkhd
sudo systemctl restart arkhd
journalctl -u arkhd -f -o cat
```
### Statesync
```
sudo systemctl stop arkhd
cp $HOME/.arkh/data/priv_validator_state.json $HOME/.arkh/priv_validator_state.json.backup
arkhd unsafe-reset-all --home ~/.arkh/

SNAP_RPC="https://rpc-arkh.sxlzptprjkt.xyz:443"
STATESYNC_PEERS="b0786057a6bcc1313477fcceaea9c78356078c6d@46.101.144.90:25656"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.arkh/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$STATESYNC_PEERS\"|" $HOME/.arkh/config/config.toml

mv $HOME/.arkh/priv_validator_state.json.backup $HOME/.arkh/data/priv_validator_state.json
sudo systemctl restart arkhd && sudo journalctl -fu arkhd -o cat
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
--fees 5000arkh
```
### Edit
```
arkhd tx staking edit-validator \
--moniker=vinjan \
--identity=7C66E36EA2B71F68 \
--commission-rate=0.04 \
--chain-id=arkh \
--from=wallt \
--fees 5000arkh
``` 
### Unjail
```
arkhd tx slashing unjail --broadcast-mode=block --from wallt --chain-id arkh --fees=5000arkh
```

### WD All
```
arkhd tx distribution withdraw-all-rewards --from wallt --chain-id arkh --gas auto
```

### WD with commission
```
arkhd tx distribution withdraw-rewards $(arkhd keys show wallt --bech val -a) --commission --from wallt --chain-id arkh --fees 1000arkh
```
### Delegate
```
arkhd tx staking delegate $(arkhd keys show wallt --bech val -a) 1000000arkh --from wallt --chain-id arkh  --fees 1000arkh
```

### Transfer
```
arkhd tx bank send wallet <TO_WALLET_ADDRESS> 1000000arkh --from wallet --chain-id arkh
```

### Unbond
```
arkhd tx staking unbond $(arkhd keys show wallet --bech val -a) 1000000arkh --from wallet --chain-id arkh --gas auto
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

 




