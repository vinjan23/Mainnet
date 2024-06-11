```

wget -O https://1501792788-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FcIZFCZY4EPKDYaPcDZLG%2Fuploads%2FOlvUYiHbP9ljhSEkXUpK%2Fselfchaind-linux-amd64?alt=media&token=8c3b22b7-dfaf-4310-95e9-e54113f18b18

wget -O selfchaind https://docs.selfchain.xyz/nodes-and-validators/releases/download/Self Chain Mainnet v1.0.0/selfchaind-linux-amd64
chmod +x selfchaind-linux-amd64
sudo mv selfchaind-linux-amd64 $HOME/go/bin/selfchaind
```
```
wget -O $HOME/.selfchain/config/genesis.json  https://gist.githubusercontent.com/pratikbin/656a18f371e7a970afd63e2da2890c81/raw/3876268b2d07ce65aece8455c67f98cf557c6e40/selfchain-mainnet-self-1.json
```
```
PORT=20
selfchaind config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.selfchain/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%" $HOME/.selfchain/config/app.toml
```
```
seeds="b307b56b94bd3a02fcad5b6904464a391e13cf48@128.199.33.181:26656,71b8d630e7c3e31f2743fda68e6d3ac64f41cece@209.97.174.97:26656,6ae10267d8581414b37553655be22297b2f92087@174.138.25.159:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.selfchain/config/config.toml
peers="b307b56b94bd3a02fcad5b6904464a391e13cf48@128.199.33.181:26656,71b8d630e7c3e31f2743fda68e6d3ac64f41cece@209.97.174.97:26656,6ae10267d8581414b37553655be22297b2f92087@174.138.25.159:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.selfchain/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0uslf\"|" $HOME/.selfchain/config/app.toml
```
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.selfchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.selfchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.selfchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.selfchain/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.selfchain/config/config.toml
```
```
sudo tee /etc/systemd/system/selfchaind.service > /dev/null <<EOF
[Unit]
Description=selfchain
After=network-online.target

[Service]
User=$USER
ExecStart=$(which selfchaind) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable selfchaind
sudo systemctl restart selfchaind
sudo journalctl -u selfchaind -f -o cat
```

