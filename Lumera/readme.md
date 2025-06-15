### Binary
```
wget https://github.com/LumeraProtocol/lumera/releases/download/v1.1.0/lumera_v1.1.0_linux_amd64.tar.gz
tar xzvf lumera_v1.1.0_linux_amd64.tar.gz
chmod +x lumerad
mv lumerad $HOME/go/bin/
rm lumera_v1.1.0_linux_amd64.tar.gz
rm install.sh
mv libwasmvm.x86_64.so /usr/lib/
```
```
mkdir -p $HOME/.lumera/cosmovisor/genesis/bin
cp $HOME/go/bin/lumerad $HOME/.lumera/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.lumera/cosmovisor/genesis $HOME/.lumera/cosmovisor/current -f
sudo ln -s $HOME/.lumera/cosmovisor/current/bin/lumerad /usr/local/bin/lumerad -f
```
### Init
```
lumerad init Vinjan.Inc --chain-id lumera-mainnet-1
```
### Genesis
```
wget -O $HOME/.lumera/config/genesis.json https://raw.githubusercontent.com/LumeraProtocol/lumera-networks/refs/heads/master/mainnet/genesis.json
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:17657\"%" $HOME/.lumera/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:17658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:17657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:17060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:17656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":17660\"%" $HOME/.lumera/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:17317\"%; s%^address = \"localhost:9090\"%address = \"localhost:17090\"%" $HOME/.lumera/config/app.toml
```
### Gas Price
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0ulume\"/" $HOME/.lumera/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "1000"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "11"|' \
$HOME/.lumera/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.lumera/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/lumerad.service > /dev/null << EOF
[Unit]
Description=lumera
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.lumera"
Environment="DAEMON_NAME=lumerad"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.lumera/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable lumerad
sudo systemctl restart lumerad
sudo journalctl -u lumerad -f -o cat
```
### Sync
```
lumerad status 2>&1 | jq .sync_info
```
### Wallet
```
lumerad keys add wallet --recover
```
### Balances
```
lumerad q bank balances $(lumerad keys show wallet -a)
```
### Validator
```
lumerad tendermint show-validator
```
```
nano $HOME/.lumera/validator.json
```
```
{
  "pubkey": ,
  "amount": "1000000ulume",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
```
```
lumerad tx staking create-validator $HOME/.lumera/validator.json \
--from wallet \
--chain-id lumera-mainnet-1 \
--gas-prices=0.025ulume \
--gas-adjustment=1.5 \
--gas=auto
```

