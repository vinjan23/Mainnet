### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
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

### Binary
```
cd $HOME
git clone https://github.com/gitopia/gitopia.git
cd gitopia
git checkout v2.0.0
make install
```
### Update
```
cd $HOME
cd gitopia
git fetch --tag
git checkout v2.1.1
make install
```

### Init Moniker
```
MONIKER=
```
```
gitopiad init $MONIKER --chain-id gitopia
gitopiad config chain-id gitopia
gitopiad config keyring-backend file
```
### Custom Port
```
PORT=44
gitopiad config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.gitopia/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.gitopia/config/app.toml
```

#### Genesis
```
cd && git clone https://github.com/gitopia/mainnet && cd mainnet
tar -xzf genesis.tar.gz
cp genesis.json ~/.gitopia/config/genesis.json
```

### Addrbook
```
wget -O $HOME/.decentr/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/main/Gitopia/addrbook.json
```
### Seed & Peer & Gas
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulore\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.gitopia/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.gitopia/config/config.toml
peers="4cf66531681c92f15c95c25bd1bff524f9dca35e@65.109.154.181:26656,b2f764694d52e09793d68259d584ece0c194b6fe@65.108.229.93:26656,11879f38e16e1723ef70950f5222ec78dde7e62f@65.109.17.23:56240,70e0603c1557681ee5d749b82c27468aecc862f1@185.246.85.5:26656,23c825fd57b6c893503157a637b92e1eaf46da71@65.108.200.40:26656,33e2390bfd693a8f2b27d5d646e0f081d717a81f@135.181.73.57:26656,082e95b5d5351e68dcfb24dff802f9064cfd5a4c@65.109.92.241:51056"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.gitopia/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.gitopia/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.gitopia/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.gitopia/config/config.toml
```

### Prunning
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.gitopia/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.gitopia/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.gitopia/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.gitopia/config/app.toml
```

### Indexer
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.gitopia/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/gitopiad.service > /dev/null <<EOF
[Unit]
Description=gitopia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gitopiad) start
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
sudo systemctl enable gitopiad
sudo systemctl restart gitopiad
sudo journalctl -u gitopiad -f -o cat
```

### Sync
```
gitopiad status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u gitopiad -f -o cat
```

### Wallet
```
gitopiad keys add wallet --recover
```

### Balances
```
gitopiad query bank balances gitopia1rca4acwwccvakhgzleyl4j6vry4z36ypsx7h2r
```

#### Validator
```
gitopiad tx staking create-validator \
--amount 210000000ulore \
--from wallet \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.2" \
--commission-rate "0.1" \
--min-self-delegation "1" \
--pubkey  $(gitopiad tendermint show-validator) \
--moniker vinjan \
--chain-id gitopia \
--identity="7C66E36EA2B71F68" \
--details="🎉Proffesional Stake & Node Validator🎉" \
--website="https://nodes.vinjan.xyz" \
--gas-adjustment 1.4 \
--gas auto \
-y
```
### Edit
```
gitopiad tx staking edit-validator \
--new-moniker vinjan \
--from wallet \
--identity 7C66E36EA2B71F68 \
--details="🎉Stake Here Berhadiah MiChat🎉" \
--chain-id gitopia \
--commission-rate "0.09" \
--gas-adjustment 1.4 \
--gas auto \
-y
```

### Unjail
```
gitopiad tx slashing unjail --from wallet --chain-id --chain-id gitopia --gas-adjustment="1.4" --gas auto -y
```

### Withdraw 
```
gitopiad tx distribution withdraw-all-rewards --from wallet --chain-id gitopia --gas-adjustment="1.4" --gas auto -y
```
```
gitopiad tx distribution withdraw-rewards $(gitopiad keys show wallet --bech val -a) --commission --from wallet --chain-id gitopia --gas-adjustment="1.4" --gas auto -y
```

### Delegate
```
gitopiad tx staking delegate $(gitopiad keys show wallet --bech val -a) 1000000ulore --from wallet --chain-id gitopia --gas-adjustment="1.4" --gas auto -y
```
### Check Match Validator
```
[[ $(gitopiad q staking validator $(gitopiad keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(gitopiad status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Check Own Peer
```
echo $(gitopiad tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.gitopia/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
### Connected Peer
```
curl -sS http://localhost:44657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Node Info
```
gitopiad status 2>&1 | jq .NodeInfo
```
### Validator Info
```
gitopiad status 2>&1 | jq .ValidatorInfo
```
### Delete Node
```
sudo systemctl stop gitopiad && \
sudo systemctl disable gitopiad && \
rm /etc/systemd/system/gitopiad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf gitopia && \
rm -rf .gitopiad && \
rm -rf $(which gitopiad)
```







