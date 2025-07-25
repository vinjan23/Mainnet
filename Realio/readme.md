### GO
```
ver="1.22.5"
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
rm -rf realio-network
git clone https://github.com/realiotech/realio-network.git
cd realio-network
git checkout v1.2.0
make install
```
```
mkdir -p $HOME/.realio-network/cosmovisor/genesis/bin
cp $HOME/go/bin/realio-networkd $HOME/.realio-network/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.realio-network/cosmovisor/genesis $HOME/.realio-network/cosmovisor/current -f
sudo ln -s $HOME/.realio-network/cosmovisor/current/bin/realio-networkd /usr/local/bin/realio-networkd -f
```
### Update
```
cd $HOME
rm -rf realio-network
git clone https://github.com/realiotech/realio-network.git
cd realio-network
git checkout v1.3.1
make install
```

```
mkdir -p $HOME/.realio-network/cosmovisor/upgrades/v1.3.1/bin
cp $HOME/go/bin/realio-networkd $HOME/.realio-network/cosmovisor/upgrades/v1.3.0/bin/
```
```
sudo systemctl stop realio-networkd
ls -l $HOME/.realio-network/cosmovisor/current
rm $HOME/.realio-network/cosmovisor/current
ln -s $HOME/.realio-network/cosmovisor/upgrades/v1.3.1 $HOME/.realio-network/cosmovisor/current
```

```
cd $HOME
rm -rf realio-network
git clone https://github.com/realiotech/realio-network.git
cd realio-network
git checkout v1.3.1
make build
```
```
mkdir -p $HOME/.realio-network/cosmovisor/upgrades/v1.3.0/bin
mv build/realio-networkd $HOME/.realio-network/cosmovisor/upgrades/v1.3.1/bin/
rm -rf build
```
```
realio-networkd version --long | grep -e commit -e version
```
```
$HOME/.realio-network/cosmovisor/upgrades/v1.3.1/bin/realio-networkd version --long | grep -e commit -e version
```
```
sudo systemctl restart realio-networkd
sudo journalctl -u realio-networkd -f -o cat
```

### Moniker
```
MONIKER=
```

### Init
```
realio-networkd init $MONIKER --chain-id realionetwork_3301-1
realio-networkd config chain-id realionetwork_3301-1
realio-networkd config keyring-backend file
```

### Custom Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:22657\"%" $HOME/.realio-network/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:22658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:22657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:22060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:22656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":22660\"%" $HOME/.realio-network/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:22317\"%; s%^address = \"localhost:9090\"%address = \"localhost:22090\"%; s%^address = \"127.0.0.1:8545\"%address = \"127.0.0.1:22545\"%; s%^ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:22546\"%; s%^metrics-address = \"127.0.0.1:6065\"%metrics-address = \"127.0.0.1:22065\"%" $HOME/.realio-network/config/app.toml
```

### Genesis
```
wget -O $HOME/.realio-network/config/genesis.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Realio/genesis.json
```

### Addrbook
```
wget -O $HOME/.realio-network/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Realio/addrbook.json"
```

### Seed & Peer & Gas
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0ario\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.realio-network/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.realio-network/config/config.toml
peers="b2e50a471151aecedde282055a8f0e829aa2170b@65.109.29.224:28656,759b796d1f7c8c8362b525aaad2531591762723a@88.198.32.17:46656,5d2c9ea486a09700435ee1c0ba5291f8f1078c96@10.233.89.226:26656,4361e0e3f73ece1e6fcb9f603f0ba4ccd8ae957b@142.132.202.50:39656,9521958ef1eea934bba7f28376b7341e4dbb5f36@65.109.104.118:60856,00b261d9c9b845ce42964a3a3f6c68173875e981@65.109.28.177:30656,2c832dcd9e41d988fadf8d1af8d95640ce009398@realio.sergo.dev:12263,2e594b4782b7273ebebe47351885842c85abe8f5@65.108.229.93:32656,704eb376ec58ce6b4d1df7dfd7f0be7e79d5f200@5.9.147.22:23656,271f194229b4ee9be89777daa3ef8201553865cc@mainnet-realio.konsortech.xyz:35656,6e148794b697c64f54956ff18ca3d22fc9d95c96@148.113.6.169:30656,4a98ef79d9c80016766e247b10afe46f4cdb9892@95.216.114.212:18656,a09acd01e40c94b58cb9109fa74ce53c2220fd26@161.97.182.71:46656,cd9d9af6b7a99af3c5c920f7a054d37e297222e4@65.108.224.156:13656,daea809589ac871c6c9f450ca1cdfd5ab2320e06@57.128.110.81:26656,b09d477f5b59e5e99632ad3a8a11806381efa46f@realio.peers.stavr.tech:21096,e9cfaccc92b425fc48f2671ae9fab25c3d25926c@142.132.194.157:26557,d99c807a58f876684618af016409a09186065851@173.249.59.70:32656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.realio-network/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.realio-network/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.realio-network/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.realio-network/config/config.toml
```

### Prunning
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="19" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.realio-network/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.realio-network/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.realio-network/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.realio-network/config/app.toml
```

### Indexer Null
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.realio-network/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/realio-networkd.service > /dev/null << EOF
[Unit]
Description=realio-network
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.realio-network"
Environment="DAEMON_NAME=realio-networkd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.realio-network/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable realio-networkd
sudo systemctl restart realio-networkd
sudo journalctl -u realio-networkd -f -o cat
```

### Sync
```
realio-networkd status 2>&1 | jq .sync_info
```

### Log
```
sudo journalctl -u realio-networkd -f -o cat
```
### Statesync
```
sudo systemctl stop realio-networkd
realio-networkd tendermint unsafe-reset-all --home $HOME/.realio-network --keep-addr-book
SNAP_RPC=https://rpc-realio.vinjan.xyz:443
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.realio-network/config/config.toml
sudo systemctl restart realio-networkd && journalctl -u realio-networkd -f -o cat
```
### Turnoff Statesync
```
sed -i -e "s|^enable *=.*|enable = false|" $HOME/.realio-network/config/config.toml
```
### Wallet
```
realio-networkd keys add wallet --recover
```
### Balances
```
realio-networkd q bank balances $(realio-networkd keys show wallet -a)
```

### Validator
`RIO`
```
realio-networkd tx staking create-validator \
  --amount=1000000000000000000ario \
  --pubkey=$(realio-networkd tendermint show-validator) \
  --moniker="vinjan" \
  --website="https://nodes.vinjan.xyz" \
  --identity="7C66E36EA2B71F68" \
  --chain-id=realionetwork_3301-1 \
  --commission-rate="0.01" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.1" \
  --min-self-delegation="1" \
  --gas-prices 30000000000ario \
  --gas 1000000 \
  --from=wallet \
  -y
  ```
`RST`  
```
realio-networkd tx staking create-validator \
  --amount=5000000000000000000arst \
  --pubkey=$(realio-networkd tendermint show-validator) \
  --moniker="vinjan" \
  --website="https://nodes.vinjan.xyz" \
  --identity="7C66E36EA2B71F68" \
  --chain-id=realionetwork_3301-1 \
  --commission-rate="0.05" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.1" \
  --min-self-delegation="1" \
  --from=wallet \
  --gas-prices 30000000000ario \
  --gas 1000000 \
  -y
```
```
realio-networkd tx bank send wallet realio1zdq2ql5gua8mda627t5p3870c4xvykr6n47qvd 5150000000000000000ario --from wallet --chain-id realionetwork_3301-1 --gas 800000 --fees 16000000000000000ario -y 
```

### Edit
```
realio-networkd tx staking edit-validator \
--new-moniker "Vinjan.Inc | RIO" \
--identity "7C66E36EA2B71F68" \
--chain-id "realionetwork_3301-1" \
--commission-rate="0.06" \
--from wallet \
--gas 800000 \
--fees 5000000000000000ario
```

### Unjail
```
realio-networkd tx slashing unjail --from wallet --chain-id realionetwork_3301-1 --gas 800000 --fees 16000000000000000ario
```

### Delegate
```
realio-networkd tx staking delegate $(realio-networkd keys show wallet --bech val -a) 470000000000000000almx --from wallet --chain-id realionetwork_3301-1 --gas 800000 --fees 16000000000000000ario
```

### Withdraw with comission
```
realio-networkd tx distribution withdraw-rewards $(realio-networkd keys show wallet --bech val -a) --from wallet --commission --chain-id realionetwork_3301-1 --gas 800000 --fees 16000000000000000ario
```

### Stop
```
sudo systemctl stop realio-networkd
```

### Restart
```
sudo systemctl restart realio-networkd
```

### Check Validator
```
[[ $(realio-networkd q staking validator realiovaloper1csj5g5j4r682apvjckdk3qldkup4y07472gtkh -oj | jq -r .consensus_pubkey.key) = $(realio-networkd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\nYou win\n" || echo -e "\nYou lose\n"
```
```
[[ $(realio-networkd q staking validator $(realio-networkd keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(realio-networkd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Own peer
```
echo $(realio-networkd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.realio-network/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Connected Peer
```
curl -sS http://localhost:22657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### Vote
```
realio-networkd tx gov vote 22 yes --from wallet --chain-id realionetwork_3301-1 --gas 800000 --fees 16000000000000000ario
```
### Deposit
```
realio-networkd tx gov deposit 8 5000000000000000000ario --from wallet --chain-id realionetwork_3301-1 --fees 70000000000ario
```
### Delete
```
sudo systemctl stop realio-networkd && \
sudo systemctl disable realio-networkd && \
rm /etc/systemd/system/realio-networkd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf realio-network
rm -rf .realio-network
rm -rf $(which realio-networkd)
```




