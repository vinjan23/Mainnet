```
cd $HOME
rm -rf kopi
git clone --quiet --depth 1 --branch v0.6.5 https://github.com/kopi-money/kopi.git
cd kopi
make install
```

```
kopid init Vinjan.Inc --chain-id luwak-1
```

```
wget -q https://data.kopi.money/genesis.json -O ~/.kopid/config/genesis.json
```

```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:45657\"%" $HOME/.kopid/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:45658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:45657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:45060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:45656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":45660\"%" $HOME/.kopid/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:45317\"%; s%^address = \"localhost:9090\"%address = \"localhost:45090\"%" $HOME/.kopid/config/app.toml
```

```
seeds="85919e3dcc7eec3b64bfdd87657c4fac307c9d23@65.109.34.145:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.kopid/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ukopi\"/;" ~/.kopid/config/app.toml
```

```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.kopid/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.kopid/config/config.toml
```
```
sudo tee /etc/systemd/system/kopid.service > /dev/null << EOF
[Unit]
Description=kopi
After=network-online.target
[Service]
User=$USER
ExecStart=$(which kopid) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable kopid
sudo systemctl restart kopid
sudo journalctl -u kopid -f -o cat
```



