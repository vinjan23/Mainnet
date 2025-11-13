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
git checkout v1.4.0
make install
```

```
mkdir -p $HOME/.realio-network/cosmovisor/upgrades/v1.4.0/bin
cp -a $HOME/go/bin/realio-networkd $HOME/.realio-network/cosmovisor/upgrades/v1.4.0/bin/
```

```
cd $HOME
rm -rf realio-network
git clone https://github.com/realiotech/realio-network.git
cd realio-network
git checkout v1.4.0
make build
```
```
mkdir -p $HOME/.realio-network/cosmovisor/upgrades/v1.4.0/bin
mv build/realio-networkd $HOME/.realio-network/cosmovisor/upgrades/v1.4.0/bin/
rm -rf build
```
```
realio-networkd version --long | grep -e commit -e version
```
```
$HOME/.realio-network/cosmovisor/upgrades/v1.4.0/bin/realio-networkd version --long | grep -e commit -e version
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
PORT=22
sed -i -e "s%:26657%:${PORT}657%" $HOME/.realio-network/config/client.toml
sed -i -e "s%:26658%:${PORT}658%; s%:26657%:${PORT}657%; s%:6060%:${PORT}060%; s%:26656%:${PORT}656%; s%:26660%:${PORT}661%" $HOME/.realio-network/config/config.toml
sed -i -e "s%:1317%:${PORT}317%; s%:9090%:${PORT}090%" $HOME/.realio-network/config/app.toml
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
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.realio-network/config/app.toml
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
realio-networkd tx slashing unjail --from wallet --chain-id realionetwork_3301-1 --gas 800000 --fees 5000000000ario
```

### Delegate
```
realio-networkd tx staking delegate $(realio-networkd keys show wallet --bech val -a) 470000000000000000almx --from wallet --chain-id realionetwork_3301-1 --gas 800000 --gas-prices 30000000000ario
```

### Withdraw with comission
```
realio-networkd tx distribution withdraw-rewards $(realio-networkd keys show wallet --bech val -a) --from wallet --commission --chain-id realionetwork_3301-1 --gas 800000 --gas-prices 30000000000ario
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




