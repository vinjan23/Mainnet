### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### GO
```
ver="1.20.4"
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
git clone https://github.com/CosmosContracts/juno.git
cd juno
git checkout v15.0.0
make install
```
### Init
```
junod config chain-id juno-1
junod config keyring-backend file
```
### PORT
```
PORT=38
junod config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.juno/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.juno/config/app.toml
```
### Binary
```
wget -O $HOME/.juno/config/genesis.json "https://snapshots.polkachu.com/genesis/juno/genesis.json --inet4-only"
```
### Seed
```
seeds="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:12656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.juno/config/config.toml
PEERS="0858341ab2e1cbe062c4a8d82223afbd9610a8ff@65.109.93.44:12656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.juno/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025ujuno\"|" $HOME/.juno/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.juno/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/junod.service > /dev/null << EOF
[Unit]
Description=juno
After=network-online.target

[Service]
User=$USER
ExecStart=$(which junod) start
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
sudo systemctl enable junod
sudo systemctl restart junod
sudo journalctl -u junod -f -o cat
```
### Sync
```
junod status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -u junod -f -o cat
```
### Snapshot
```
sudo systemctl stop junod
junod tendermint unsafe-reset-all --home $HOME/.juno --keep-addr-book
wget -O juno_9203736.tar.lz4 https://snapshots.polkachu.com/snapshots/juno/juno_9203736.tar.lz4 --inet4-only
lz4 -c -d juno_9203736.tar.lz4  | tar -x -C $HOME/.juno
sudo systemctl restart junod
sudo journalctl -u junod -f -o cat
```
### Wallet
```
starsd keys add ibc-juno
```
### Delete
```
sudo systemctl stop junod
sudo systemctl disable junod
sudo rm /etc/systemd/system/junod.service
sudo systemctl daemon-reload
rm -f $(which junod)
rm -rf $HOME/.junod
rm -rf $HOME/juno
```

