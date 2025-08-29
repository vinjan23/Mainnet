```
cd $HOME
rm -rf paxi
git clone https://github.com/paxi-web3/paxi.git
cd paxi
git checkout latest-main
make install
```
```
cp $HOME/paxid/paxid $HOME/go/bin
```
```
rm /usr/lib/libwasmvm.x86_64.so
wget -P /usr/lib https://github.com/CosmWasm/wasmvm/releases/download/v2.2.1/libwasmvm.x86_64.so
sudo ldconfig
```
```
mkdir -p $HOME/.paxi/cosmovisor/genesis/bin
cp $HOME/paxid/paxid $HOME/.paxi/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.paxi/cosmovisor/genesis $HOME/.paxi/cosmovisor/current -f
sudo ln -s $HOME/.paxi/cosmovisor/current/bin/paxid /usr/local/bin/paxid -f
```
```
paxid init Vinjan.Inc --chain-id paxi-mainnet --home $HOME/.paxi
```
```
PORT=166
sed -i -e "s%:26657%:${PORT}657%" $HOME/.paxi/config/client.toml
sed -i -e "s%:26658%:${PORT}658%; s%:26657%:${PORT}657%; s%:6060%:${PORT}060%; s%:26656%:${PORT}656%; s%:26660%:${PORT}661%" $HOME/.paxi/config/config.toml
sed -i -e "s%:1317%:${PORT}317%; s%:9090%:${PORT}090%" $HOME/.paxi/config/app.toml
```
```
wget -O $HOME/.paxi/config/genesis.json http://rpc.paxi.info/genesis? | jq -r .result.genesis
```
```
peers="d411fc096e0d946bbd2bdea34f0f9da928c1a714@139.99.68.32:26656,7299b10c0a1545f50c1911b188c579a5e8c5072f@139.99.68.235:26656,509b20ca82d34d0aae1751a681ee386659fb71da@66.70.181.55:26656,57b44498315f013558e342827f352db790d5d90c@142.44.142.121:26656,a325cced9b360c0e5fcbf756e0b1ca139b8f2eef@51.75.54.185:26656,9e64baa45042ae29d999f2677084c9579972722c@139.99.69.74:26656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.paxi/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.05upaxi\"/" $HOME/.paxi/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.paxi/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.paxi/config/config.toml
```
```
sudo tee /etc/systemd/system/paxid.service > /dev/null << EOF
[Unit]
Description=paxi
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.paxi"
Environment="DAEMON_NAME=paxid"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.paxi/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable paxid
sudo systemctl restart paxid
sudo journalctl -u paxid -f -o cat
```

```
sudo systemctl stop paxid
sudo systemctl disable paxid
rm /etc/systemd/system/paxid.service
sudo systemctl daemon-reload
rm -rf $(which paxid)
rm -rf paxi
rm -rf paxid
rm -rf .paxi
```

