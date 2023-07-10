### Package
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### GO
```
ver="1.19.3"
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
git clone https://github.com/Team-Kujira/core.git
cd core
git checkout v0.8.7
make install
```
### Config
```
kujirad config chain-id kaiyo-1
kujirad config keyring-backend file
```
### Port
```
PORT=35
kujirad config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.kujira/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.kujira/config/app.toml
```
### Genesis
```
wget -O $HOME/.kujira/config/genesis.json "https://snapshots.polkachu.com/genesis/kujira/genesis.json --inet4-only"
```
### Seed
```
seeds="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:11856"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.kujira/config/config.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.kujira/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/kujirad.service > /dev/null << EOF
[Unit]
Description=kujirad
After=network-online.target

[Service]
User=$USER
ExecStart=$(which kujirad) run start
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
sudo systemctl enable kujirad
sudo systemctl restart kujirad
sudo journalctl -u kujirad -f -o cat
```

### Sync
```
kujirad status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -u kujirad -f -o cat
```

### Recover Wallet
```
kujirad keys add wallet --recover
```
```
kujirad keys add KUJIRA_REL_WALLET --recover
```
