### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install git build-essential curl jq libclang-dev clang cmake gcc -y
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
git clone https://github.com/realiotech/realio-network.git
cd realio-network
git checkout v0.8.0-rc4
make install
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

### Genesis
```
curl https://raw.githubusercontent.com/realiotech/mainnet/master/realionetwork_3301-1/genesis.json > $HOME/.realio-network/config/genesis.json
```

### Addrbook
```
wget -O $HOME/.realio-network/config/addrbook.json https://snapshot.genznodes.dev/addrbook/realio/addrbook.json
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
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.realio-network/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.realio-network/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.realio-network/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.realio-network/config/app.toml
```

### Service
```
sudo tee /etc/systemd/system/realio-networkd.service > /dev/null <<EOF
[Unit]
Description=realio
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which realio-networkd) start
Restart=on-failure
LimitNOFILE=65535

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
realio-networkd status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u realio-networkd -f -o cat
```

### Wallet
```
realio-networkd keys add wallet --recover
```

### Balances
```
realio-networkd q bank balances <address>
```

### Validator
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
  --fees 5000000000000000ario \
  --gas 800000
  --from=wallet
  ```
  




