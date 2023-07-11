###
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
git clone https://github.com/osmosis-labs/osmosis.git
cd osmosis
git checkout v16.0.0
make install
```
### Init
```
osmosisd config chain-id osmosis-1
osmosisd config keyring-backend file
```
```
PORT=35
osmosisd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.osmosisd/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.osmosisd/config/app.toml
```
### Genesis
```
curl -Ls https://snapshots.kjnodes.com/osmosis/genesis.json > $HOME/.osmosisd/config/genesis.json
```
### Addrbook
```
curl -Ls https://snapshots.kjnodes.com/osmosis/addrbook.json > $HOME/.osmosisd/config/addrbook.json
```
### Seed
```
seeds="400f3d9e30b69e78a7fb891f60d76fa3c73f0ecc@osmosis.rpc.kjnodes.com:12959"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.osmosisd/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025uosmo\"|" $HOME/.osmosisd/config/app.toml
peers="f3262b9f490720920b0002fadd500af1cef3e6a6@51.222.40.84:26656,2f4c0337b2522034a614a5cb2c61a891fe753c03@5.9.81.187:29656,c7fb97358712f447ca0689e814fe8c965a71b314@65.21.133.114:26656,e1b058e5cfa2b836ddaa496b10911da62dcf182e@23.88.21.234:26656,a2024229e2eed1650ba3a3ea9db67fa318dc232e@142.132.199.3:26656,ac2fbcb5de633d136a942c28c3049e3edbc6e69a@85.239.233.61:2000,82e224c9640048a6513c589e904c0d903bb99f32@74.118.140.23:26656,2048e1bc1f020fa210fb475e7a0ec0948919609f@185.217.125.64:26656,d9bfa29e0cf9c4ce0cc9c26d98e5d97228f93b0b@65.108.233.103:12956"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.osmosisd/config/config.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.osmosisd/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/osmosisd.service > /dev/null << EOF
[Unit]
Description=osmosis-mainnet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which osmosisd) start
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
sudo systemctl enable osmosisd
sudo systemctl restart osmosisd
sudo journalctl -u osmosisd -f -o cat
```
### Sync
```
osmosisd status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -u osmosisd -f -o cat
```
### Delete
```
sudo systemctl stop osmosisd
sudo systemctl disable osmosisd
sudo rm /etc/systemd/system/osmosisd.service
sudo systemctl daemon-reload
rm -f $(which osmosisd)
rm -rf $HOME/.osmosisd
rm -rf $HOME/osmosis
```
