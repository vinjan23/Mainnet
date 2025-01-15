###
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
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
rm -rf osmosis
git clone https://github.com/osmosis-labs/osmosis.git
cd osmosis
git checkout v28.0.0
make build
```

### Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```
```
mkdir -p $HOME/.osmosisd/cosmovisor/genesis/bin
mv build/osmosisd $HOME/.osmosisd/cosmovisor/genesis/bin/
rm -rf build
```
```
ln -s $HOME/.osmosisd/cosmovisor/genesis $HOME/.osmosisd/cosmovisor/current -f
sudo ln -s $HOME/.osmosisd/cosmovisor/current/bin/osmosisd /usr/local/bin/osmosisd -f
```
### Update Cosmovisor
```
cd $HOME
rm -rf osmosis
git clone https://github.com/osmosis-labs/osmosis.git
cd osmosis
git checkout v28.0.0
make build
```
```
mkdir -p $HOME/.osmosisd/cosmovisor/upgrades/v28/bin
mv build/osmosisd $HOME/.osmosisd/cosmovisor/upgrades/v28/bin/
rm -rf build
```
```
mkdir -p $HOME/.osmosisd/cosmovisor/upgrades/v28/bin
cd $HOME
rm -rf osmosis
git clone https://github.com/osmosis-labs/osmosis.git
cd osmosis
git checkout v28.0.0
make install
cp -a ~/go/bin/osmosisd ~/.osmosisd/cosmovisor/upgrades/v28/bin/osmosisd
```
```
cosmovisor add-upgrade v28.0.0 /root/.osmosisd/cosmovisor/upgrades/v28/bin/osmosisd --force --upgrade-height 25861100
```
```
osmosisd version --long | grep -e commit -e version
```
### Init
```
osmosisd init Vinjan.Inc --chain-id osmosis-1
```
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:18657\"%" $HOME/.osmosisd/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:18658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:18657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:18060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:18656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":18660\"%" $HOME/.osmosisd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:18317\"%; s%^address = \"localhost:9090\"%address = \"localhost:18090\"%" $HOME/.osmosisd/config/app.toml
```
### Genesis
```
wget -O genesis.json https://snapshots.polkachu.com/genesis/osmosis/genesis.json --inet4-only
mv genesis.json ~/.osmosisd/config
```
### Addrbook
```
wget -O addrbook.json https://snapshots.polkachu.com/addrbook/osmosis/addrbook.json --inet4-only
mv addrbook.json ~/.osmosisd/config
```
### Seed
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025uosmo\"|" $HOME/.osmosisd/config/app.toml
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
Description=osmosis
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.osmosisd"
Environment="DAEMON_NAME=osmosisd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.osmosisd/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable osmosisd
```
```
sudo systemctl restart osmosisd
```
```
sudo journalctl -u osmosisd -f -o cat
```
### Sync
```
osmosisd status 2>&1 | jq .sync_info
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
