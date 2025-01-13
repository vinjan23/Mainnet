### Binary
```
cd $HOME
rm -rf ssc
git clone https://github.com/sagaxyz/ssc.git
cd ssc
git checkout v0.2.1
make install
```
### Init
```
sscd init Vinjan.Inc --chain-id ssc-1
```
### Genesis
```
curl -Ls https://ss.saga.nodestake.org/genesis.json > $HOME/.ssc/config/genesis.json
```
### Addrbook
```
curl -Ls https://ss.saga.nodestake.org/addrbook.json > $HOME/.ssc/config/addrbook.json
```
### Port 12
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:12657\"%" $HOME/.ssc/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:12658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:12657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:12060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:12656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":12660\"%" $HOME/.ssc/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:12317\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:12090\"%" $HOME/.ssc/config/app.toml
```
### Seed Peer
```
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.ssc/config/config.toml
peers=
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ssc/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025usaga\"/;" ~/.ssc/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.ssc/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/sscd.service > /dev/null <<EOF
[Unit]
Description=saga
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sscd) start
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
sudo systemctl enable sscd
sudo systemctl restart sscd
sudo journalctl -u sscd -f -o cat
```
### Sync
```
sscd status 2>&1 | jq .sync_info
```

### Wallet
```
sscd keys add ibc-saga
```
