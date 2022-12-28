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
git clone https://github.com/planq-network/planq.git
cd planq
git fetch
git checkout v1.0.2
make install
planqd version
```

### Setup Node Name
```
NODENAME=Your_Node_Name
```

### Set Vars
```
planqd config chain-id planq_7070-2
planqd init $NODENAME --chain-id planq_7070-2
planqd config node tcp://localhost:26657
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
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.planqd/config/config.toml
sed -i -e "s%^moniker *=.*%moniker = \"$moniker\"%; " $HOME/.planqd/config/config.toml
sed -i -e "s%^indexer *=.*%indexer = \"null\"%; " $HOME/.planqd/config/config.toml
sed -i -e "s%^persistent_peers *=.*%persistent_peers = \"$PEER\"%; " $HOME/.planqd/config/config.toml

SNAP_RPC1="http://bd-evmos-mainnet-state-sync-us-01.bdnodes.net:26657"
SNAP_RPC="http://bd-evmos-mainnet-state-sync-eu-01.bdnodes.net:26657"
CHAIN_ID="planq_7070-2"
PEER="96557e26aabf3b23e8ff5282d03196892a7776fc@bd-evmos-mainnet-state-sync-us-01.bdnodes.net,dec587d55ff38827ebc6312cedda6085c59683b6@bd-evmos-mainnet-state-sync-eu-01.bdnodes.net"
sed -i -e "s%^indexer *=.*%indexer = \"null\"%; " $HOME/.planqd/config/config.toml
sed -i -e "s%^persistent_peers *=.*%persistent_peers = \"$PEER\"%; " $HOME/.planqd/config/config.toml
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book
```


### Create Service File
```
sudo tee /etc/systemd/system/planqd.service > /dev/null <<EOF
[Unit]
Description=planqd
After=network-online.target

[Service]
User=$USER
ExecStart=$(which planqd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl enable planqd.service && sudo systemctl daemon-reload
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


