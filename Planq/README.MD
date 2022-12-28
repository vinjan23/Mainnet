### Update Tool
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### GO
```
ver="1.19.1"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version
```

### Binary
```
cd $HOME
rm -rf planq
git clone https://github.com/planq-network/planq.git
cd planq
git fetch
git checkout v1.0.2
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
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book
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

### Create Service File
```
sudo tee /etc/systemd/system/planqd.service > /dev/null << EOF
[Unit]
Description=planq-mainnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.planqd"
Environment="DAEMON_NAME=planqd"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl enable planqd && sudo systemctl daemon-reload
sudo systemctl restart planqd && sudo journalctl -u planqd -f -o cat
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


