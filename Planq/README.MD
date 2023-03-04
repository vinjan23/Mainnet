<p align="right">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/108977419/221791658-6384572c-ee76-4fbd-b904-0f582e6d3368.jpg">
</p>

<p align="centre">
  <img height="400" height="auto" src="https://user-images.githubusercontent.com/108977419/209762643-3663ef27-d729-4653-aa4d-e70ad386a8c0.jpg">
</p>

### ✅️ Explorer > [Explorer Planq](https://explorer.planq.network/)

### ✅️ Docs > [Docs Planq](https://docs.planq.network/validators/mainnet.html)

#   PLANQ MAINNET

4x CPU

RAM 8 GB

STORAGE 200GB (SSD atau NVME)

`PORT=33`

### Update Tool
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
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

### Binary
```
cd $HOME
rm -rf planq
git clone https://github.com/planq-network/planq.git
cd planq
git fetch
git checkout v1.0.3
make install
mkdir -p $HOME/.planqd/cosmovisor/genesis/bin
mkdir -p ~/.planqd/cosmovisor/upgrades
cp ~/go/bin/planqd ~/.planqd/cosmovisor/genesis/bin
```

### Install Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```

### Setup Node Name
```
NODE_MONIKER=Your_NODENAME 
```

### Set Vars
```
planqd config chain-id planq_7070-2
planqd init $NODE_MONIKER --chain-id planq_7070-2
planqd config keyring-backend file
planqd config node tcp://localhost:33657
```

### Download Genesis
```
wget https://raw.githubusercontent.com/planq-network/networks/main/mainnet/genesis.json
mv genesis.json ~/.planqd/config/
planqd validate-genesis
```

### Download addrbook
```
wget -O $HOME/.planqd/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/Planq/addrbook.json"
```

### Setup Seed
```
SEEDS=`curl -sL https://raw.githubusercontent.com/planq-network/networks/main/mainnet/seeds.txt | awk '{print $1}' | paste -s -d, -`
sed -i.bak -e "s/^seeds =.*/seeds = \"$SEEDS\"/" ~/.planqd/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.planqd/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.planqd/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0aplanq\"/;" ~/.planqd/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.planqd/config/config.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.planqd/config/config.toml
```

### Prunning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.planqd/config/app.toml
```

### Custom Port
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:33658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:33657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:33060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:33656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":33660\"%" $HOME/.planqd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:33317\"%; s%^address = \":8080\"%address = \":33080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:33090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:33091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:33545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:33546\"%" $HOME/.planqd/config/app.toml
```

### Disable Indexing
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.planqd/config/config.toml
```

### Create Service File
```
sudo tee /etc/systemd/system/planqd.service > /dev/null << EOF
[Unit]
Description=planq-mainnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=always
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.planqd"
Environment="DAEMON_NAME=planqd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl enable planqd && sudo systemctl daemon-reload
sudo systemctl restart planqd && sudo journalctl -u planqd -f -o cat
```

### Sync Info
```
planqd status 2>&1 | jq .SyncInfo
```

### State Sync `Optional`
```
sudo systemctl stop planqd
cp $HOME/.planqd/data/priv_validator_state.json $HOME/.planqd/priv_validator_state.json.backup
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book
SNAP_RPC="https://rpc.planq.network:443" \
SNAP_RPC2="https://rpc.planq.network:443" 
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
PEERS=$(curl -sL https://raw.githubusercontent.com/planq-network/networks/main/mainnet/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -)
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.planqd/config/config.toml
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.planqd/config/config.toml
mv $HOME/.planqd/priv_validator_state.json.backup $HOME/.planqd/data/priv_validator_state.json
sudo systemctl restart planqd
sudo journalctl -u planqd -f -o cat
```
### Snapshot
```
sudo apt update 
sudo apt install snapd -y 
sudo snap install lz4 
sudo systemctl stop planqd
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book
curl -L https://snap.nodexcapital.com/planq/planq-latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.planqd
sudo systemctl restart planqd
journalctl -fu planqd -o cat
```

### Create Wallet
```
planqd keys add <Wallet>
```

### Recover Wallet
```
planqd keys add wallet --recover
```

### Import Wallet
```
planqd keys unsafe-import-eth-key <Wallet> <PK> --keyring-backend file
```

### List Wallet
```
planqd keys list
```

### Check Balances
 ```
 planqd query bank balances <wallet_address>
 ```
 
### Create Validator
```
planqd tx staking create-validator \
  --amount=1000000000aplanq \
  --pubkey=$(planqd tendermint show-validator) \
  --chain-id=planq_7070-2 \
  --commission-rate="0.05" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1000000" \
  --from=<Wallet>
  --moniker=$NODE_MONIKER \
  --identity=B9FD76B74CE3CA7D \
  --details=satsetsatseterror \
  --gas-adjustment="1.15" \
  --gas-prices 20000000000aplanq \
  --gas 1000000 \
  ```
  
 ### Edit Validator
 ```
planqd tx staking edit-validator \
  --new-moniker=<Your_Moniker> \
  --identity=B9FD76B74CE3CA7D \
  --website="<your_website>" \
  --details=satsetsatseterror \
  --chain-id=planq_7070-2 \
  --from=<WalletName> \
  --gas 1000000 \
  --gas-adjustment="1.15" \
  --gas-prices="20000000000aplanq" \
```

### Unjail
```
planqd tx slashing unjail --gas="1000000" --gas-adjustment="1.15" --gas-prices="30000000000aplanq" --chain-id planq_7070-2 --from vj
```

### Delegate & Staking
```
planqd tx staking delegate <YOUR_TO_Validator_ADDRESS> 1000000aplanq --from <Wallet> --chain-id planq_7070-2 --gas-adjustment 1.15 --gas=1000000 --gas-prices=20000000000aplanq 
 
```
##$ Check Your Voting Power
```
apt install jq -y
curl -s localhost:<PORT>657/status | jq .result.validator_info.voting_power
```

### Transfer Fund
```
planqd tx bank send <Wallet> <To_Address> 19950000aplanq --from <Wallet> --chain-id planq_7070-2 --gas-adjustment 1.15 --gas-prices 20000000000aplanq --gas 1000000
```

### Withdraw All Reward
```
planqd tx distribution withdraw-all-rewards --from <WalletName> --chain-id planq_7070-2 --gas-prices 20000000000aplanq --gas-adjustment 1.15 --gas 1000000 
```

### Withdraw with Commission
```
planqd tx distribution withdraw-rewards $(planqd keys show <key_name> --bech val -a) --commission --gas="1000000" --gas-adjustment="1.15" --gas-prices="20000000000aplanq" --chain-id planq_7070-2 --from <key_name>
```

### Checj Your Valoper Address
```
planqd keys show <key_name> --bech val -a
```

### Check Planq Address
```
planqd keys show <key_name> -a
```

### Check Your Own Peer
```
echo $(planqd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.planqd/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Check Your Connected Peer
```
curl -sS http://localhost:<$PORT>657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### Check Log
```
journalctl -fu planqd -o cat
```

### Node Info
```
planqd status 2>&1 | jq .NodeInfo
```

### Validator Info
```
planqd status 2>&1 | jq .ValidatorInfo
```
### Check Your Validator
```
planqd query staking validator $(planqd keys show $(planqd keys list --output json| jq -r ".[] .address" | tail -n1) --bech val -a) --chain-id planq_7070-2
```

### Check validator Matches
```
[[ $(planqd q staking validator VALOPER_ADDRESS -oj | jq -r .consensus_pubkey.key) = $(planqd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\nYou win\n" || echo -e "\nYou lose\n"
```
```
[[ $(planqd q staking validator $(planqd keys show <Wallet_Name> --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(planqd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Delete Node
```
sudo systemctl stop planqd && \
sudo systemctl disable planqd && \
rm /etc/systemd/system/planqd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf planq && \
rm -rf .planqd && \
rm -rf $(which planqd)
```
```
planqd tx staking edit-validator \
  --new-moniker=vinjan \
  --identity=7C66E36EA2B71F68 \
  --website=vinjan.xyz \
  --details=satsetsatseterror \
  --chain-id=planq_7070-2 \
  --from=vj 
  --commission-rate "0.06" \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \ 
  --gas="1000000" 
  --gas-adjustment="1.15" 
  --gas-prices="30000000000aplanq"
  ```
  

