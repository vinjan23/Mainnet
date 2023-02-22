### Update Package
```
sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### Install GO
```
ver="1.19.3"
cd $HOME
rm -rf go
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
### Build Binary
```
curl -L "https://8ball.info/8ball.tar.gz" > 8ball.tar.gz && \
tar -C ./ -vxzf 8ball.tar.gz && \
rm -f 8ball.tar.gz  && \
sudo mv ./8ball /usr/local/bin/
```
### Init
```
8ball init $MONIKER --chain-id eightball-1
8ball config chain-id eightball-1
8ball config keyring-backend file
PORT=25
8ball config node tcp://localhost:${PORT}657
```

### Download Genesis & Addrbook
```
curl -L "https://8ball.info/8ball-genesis.json" > genesis.json
mv genesis.json ~/.8ball/config/
wget -O $HOME/.8ball/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/8ball/addrbook.json"
```

### Seed & Peer
```
SEEDS=
PEERS=fca96d0a1d7357afb226a49c4c7d9126118c37e9@one.8ball.info:26656,aa918e17c8066cd3b031f490f0019c1a95afe7e3@two.8ball.info:26656,98b49fea92b266ed8cfb0154028c79f81d16a825@three.8ball.info:26656
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.8ball/config/config.toml
```

### Custom Port
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.8ball/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.8ball/config/app.toml
```

### Create Service
```
sudo tee /etc/systemd/system/8ball.service > /dev/null <<EOF
[Unit]
Description=8ball
After=network-online.target

[Service]
User=$USER
ExecStart=$(which 8ball) start --home $HOME/.8ball
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
sudo systemctl enable 8ball
sudo systemctl restart 8ball
sudo journalctl -fu 8ball -o cat
```

### Statesync
```
systemctl stop 8ball 
8ball tendermint unsafe-reset-all --home $HOME/.8ball --keep-addr-book

STATE_SYNC_RPC="https://8ball-rpc.genznodes.dev:443"

LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

PEERS=fb1aa0a42ceadeafaecb6dfa07215006b21ea1c1@154.26.138.73:28656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.8ball/config/config.toml

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/.8ball/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  $HOME/.8ball/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/.8ball/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.8ball/config/config.toml

systemctl restart 8ball && journalctl -fu 8ball -o cat
```
### Check Sync
```
8ball status 2>&1 | jq .SyncInfo
```
### Check Log
```
sudo journalctl -fu 8ball -o cat
```
### Create Wallet
```
8ball keys add wallet
```
### Recover 
```
8ball keys add wallet --recover
```

### Check Balances
```
8ball query bank balances 8ball1jf02c7l9ezy30eflx0kgp54d0tpsj2zzhef7zv
```

### Create Validator
```
8ball tx staking create-validator \
--moniker=vinjan \
--amount=50000000uebl \
--pubkey=$(8ball tendermint show-validator) \
--chain-id=eightball-1 \
--commission-rate="0.1" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="100" \
--from=wallet
--identity=7C66E36EA2B71F68 \
--details=node.vinjan.xyz \
--gas=auto \
-Y
```
### Edit Validator
```
8ball tx staking edit-validator \
 --new-moniker=vinjan \
 --identity=7C66E36EA2B71F68 \
 --website=nodes.vinjan.xyz \
 --details=satsetsatseterror \
 --chain-id=eightball-1 \
 --from=wallet \
 --gas=auto \
 -y
 ```
 ### Unjail
 ```
 8ball tx slashing unjail --broadcast-mode=block --from wallet --chain-id eightball-1 --fees=5000uebl
 ```
 
### Delegate 
```
8ball tx staking delegate 8ballvaloper1jf02c7l9ezy30eflx0kgp54d0tpsj2zz3zmn8h 888000000uebl --from wallet --chain-id eightball-1 --gas auto -y
``` 
 
### Withdraw All Reward
```
8ball tx distribution withdraw-all-rewards --from wallet --chain-id eightball-1 --gas auto -y
```
### Withdraw With Commission
```
8ball tx distribution withdraw-rewards $(8ball keys show wallet --bech val -a) --commission --chain-id eightball-1 --gas auto -y
```
### Transfer
```
8ball tx bank send address to-address 888000000uebl --from wallet --chain-id eightball-1 --fees 5000uebl
```

### Check Validator Match with Wallet
```
[[ $(8ball q staking validator $(8ball keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(8ball status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
`True=Good`

### Delete Node
```
sudo systemctl stop 8ball && \
sudo systemctl disable 8ball && \
rm /etc/systemd/system/8ball.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf 8ball && \
rm -rf .8ball && \
rm -rf $(which 8ball)
```

  
  
  








