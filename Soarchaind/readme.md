### Binary
```
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/releases/download/v1.5.2/libwasmvm.x86_64.so
```
```
cd $HOME
git clone https://github.com/soar-robotics/mainnet-rehearsal.git
cd mainnet-rehearsal/binary
tar -xvf $HOME/soarchaind.tar.gz
sudo mv soarchaind /usr/local/go/bin
```
```
soarchaind init Vinjan.Inc --chain-id soarchaintestnet-1 --default-denom utsoar
```
```
soarchaind keys add wallet --keyring-backend test --algo secp256k1 --recover
```
### Genesis
```
wget -O $HOME/.soarchain/config/genesis.json https://raw.githubusercontent.com/soar-robotics/mainnet-rehearsal/main/network/pregenesis.json
```
```
wget -O $HOME/.soarchain/config/genesis.json "https://raw.githubusercontent.com/soar-robotics/mainnet-rehearsal/main/network/genesis.json"
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:30657\"%" $HOME/.soarchain/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:30658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:30657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:30060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:30656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":30660\"%" $HOME/.soarchain/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:30317\"%; s%^address = \"localhost:9090\"%address = \"localhost:30090\"%" $HOME/.soarchain/config/app.toml
```
### Peer
```
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.soarchain/config/config.toml
```
### Prunning
```
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.soarchain/config/app.toml
```
### Indexer
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.soarchain/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/soarchaind.service > /dev/null << EOF
[Unit]
Description=Soarchain
After=network-online.target

[Service]
User=$USER
ExecStart=$(which soarchaind) start
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
sudo systemctl enable soarchaind
sudo systemctl restart soarchaind
sudo journalctl -u soarchaind -f -o cat
```
```
soarchaind start
```
