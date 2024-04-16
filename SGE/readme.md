### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### GO
```
ver="1.19" &&
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" &&
sudo rm -rf /usr/local/go &&
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" &&
rm "go$ver.linux-amd64.tar.gz" &&
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile &&
source $HOME/.bash_profile &&
go version
```
```
ver="1.21.7"
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
git clone https://github.com/sge-network/sge
cd sge
git checkout v1.5.3
make install
```
### Update
```
cd $HOME/sge
git pull
git checkout v1.5.3
make install
```
### Init
```
MONIKER=
```
```
sged init $MONIKER --chain-id sgenet-1
sged config chain-id sgenet-1
sged config keyring-backend file
```
### Port
```
PORT=17
sged config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.sge/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.sge/config/app.toml
```
### Genesis
```
wget -O $HOME/.sge/config/genesis.json "https://raw.githubusercontent.com/sge-network/networks/master/mainnet/sgenet-1/genesis.json"
```
### Seed & Peer & Gas
```
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.sge/config/config.toml
peers="55f83e1872c482caa102f54e3a73da6c6a146a3f@190.124.251.30:26656,8cb8fecf6470ceaba3f2e7b7c3442b19bd692dea@34.168.149.213:26656,be9721fb11f2ace5b59d26710b4a0d5467ddc8c9@136.243.67.44:17756,d09a5df7a13c758928ab1de0dc7342cab2e7b686@74.50.74.98:36656,401a4986e78fe74dd7ead9363463ba4c704d8759@38.146.3.183:17756,6aa15d14b1e7dadb1923e5701b22c6e370612c29@136.243.67.189:17756,033d3698baf8488429cf2af86ce7d7ad81780a39@[2001:bc8:702:1841::226]:26656,6e0bfbf0c69e60158b310783d129141f88a3c228@5.181.190.81:26656,af9d9bd15ca597eb77dab73c56b0ae51bafcbb28@142.132.202.86:16656,88f341a9670494c3d529934dc578eec1b00f4aa1@141.94.168.85:26656,a44284e563c31676f1c06ff08315d9642e0a6f59@103.230.87.171:26656,17da9d2fea9d6d431d390c3b9575547d8881da2b@185.16.39.190:11156"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sge/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usge\"/" $HOME/.sge/config/app.toml
```
### Prunning
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.sge/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.sge/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.sge/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.sge/config/app.toml
```
### Indexer Off
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sge/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/sged.service > /dev/null <<EOF
[Unit]
Description=sged
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sged) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable sged
```
```
sudo systemctl restart sged
```
```
sudo journalctl -u sged -f -o cat
```
### Sync
```
sged status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -u sged -f -o cat
```
### Wallet
```
sged keys add wallet
```
### Recover
```
sged keys add wallet --recover
```
### Balances
```
sged q bank balances $(sged keys show wallet -a)
```

### Create Validator
```
sged tx staking create-validator \
--amount=100000000usge \
--moniker=vinjan \
--identity="7C66E36EA2B71F68" \
--details=" 🎉 Stake & Node Operator 🎉" \
--website="https://service.vinjan.xyz" \
--from=wallet \
--commission-max-change-rate="0.01" \
--commission-max-rate="0.2" \
--commission-rate="0.1" \
--min-self-delegation="1" \
--pubkey=$(sged tendermint show-validator) \
--chain-id=sgenet-1 \
--gas-adjustment=1.2 \
--gas=auto \
-y
```
### Edit
```
sged tx staking edit-validator \
--new-moniker=vinjan \
--identity="" \
--details="" \
--website="" \
--from=wallet \
--chain-id=sgenet-1 \
--gas-adjustment=1.2 \
--gas=auto \
-y
```

### Unjail
```
sged tx slashing unjail --broadcast-mode=block --from wallet --chain-id sgenet-1 --gas-adjustment 1.2 --gas auto -y
```
### Reason Jail
```
sged query slashing signing-info $(sged tendermint show-validator)
```
### Delegate
```
sged tx staking delegate $(sged keys show wallet --bech val -a) 1000000usge --from wallet --chain-id sgenet-1 --gas-adjustment 1.1 --gas auto -y
```
### Withdraw
```
sged tx distribution withdraw-all-rewards --from wallet --chain-id sgenet-1 --gas-adjustment 1.2 --gas auto -y
```
### Withdraw with Commission
```
sged tx distribution withdraw-rewards $(sged keys show wallet --bech val -a) --commission --from wallet --chain-id sgenet-1 --gas-adjustment 1.2 --gas auto -y
```
### Vote
```
sged tx gov vote 1 yes --from wallet --chain-id sgenet-1 --gas-adjustment 1.2 --gas auto -y
```

### Delete
```
sudo systemctl stop sged
sudo systemctl disable sged
sudo rm /etc/systemd/system/sged.service
sudo systemctl daemon-reload
rm -f $(which sged)
rm -rf .sge
rm -rf sge
```

