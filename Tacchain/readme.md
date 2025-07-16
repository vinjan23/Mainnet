### Binary
```
cd $HOME
rm -rf tacchain
git clone https://github.com/TacBuild/tacchain.git
cd tacchain
git checkout v1.0.1
make install
```
```
mkdir -p $HOME/.tacchaind/cosmovisor/genesis/bin
cp $HOME/go/bin/tacchaind $HOME/.tacchaind/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.tacchaind/cosmovisor/genesis $HOME/.tacchaind/cosmovisor/current -f
sudo ln -s $HOME/.tacchaind/cosmovisor/current/bin/tacchaind /usr/local/bin/tacchaind -f
```
```
tacchaind  version  --long | grep -e version -e commit
```
```
$HOME/.tacchaind/cosmovisor/upgrades/v1.0.1/bin/tacchaind version --long | grep -e commit -e version
```

### Init
```
tacchaind init Vinjan.Inc --chain-id tacchain_239-1
```
### Port
```
PORT=113
sed -i -e "s|chain-id = \".*\"|chain-id = \"tacchain_239-1\"|g" $HOME/.tacchaind/config/client.toml
sed -i -e "s%:26657%:${PORT}57%" $HOME/.tacchaind/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.tacchaind/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%; s%:8545%:${PORT}45%; s%:8546%:${PORT}46%; s%:6065%:${PORT}65%" $HOME/.tacchaind/config/app.toml
```
### Genesis
```
wget -O $HOME/.tacchaind/config/genesis.json https://raw.githubusercontent.com/TacBuild/tacchain/refs/heads/main/networks/tacchain_239-1/genesis.json
```
### Addrbook
```
wget -O $HOME/.tacchaind/config/addrbook.json https://snapshots.polkachu.com/addrbook/tacchain/addrbook.json --inet4-only
```
### Gas
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"25000000000utac\"/" $HOME/.tacchaind/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.tacchaind/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.tacchaind/config/config.toml
```
### Create Service
```
sudo tee /etc/systemd/system/tacchaind.service > /dev/null << EOF
[Unit]
Description=tacchainb
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.tacchaind"
Environment="DAEMON_NAME=tacchaind"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.tacchaind/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable tacchaind
sudo systemctl restart tacchaind
sudo journalctl -u tacchaind -f -o cat
```
### Sync
```
tacchaind  status 2>&1 | jq .sync_info
```
### Wallet
```
tacchaind keys add wallet
```
```
tacchaind  keys export wallet --unarmored-hex --unsafe
```
```
tacchaind q bank balances $(tacchaind keys show wallet -a)
```
### Validator
```
tacchaind  tendermint show-validator
```
```
nano $HOME/.tacchaind/validator.json
```
```
{
  "pubkey": ,
  "amount": "1000000000000000000utac",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.2",
  "min-self-delegation": "1"
}
```
```
tacchaind tx staking create-validator $HOME/.tacchaind/validator.json \
--from wallet \
--chain-id tacchain_2391-1 \
--gas-prices=4000000000000utac \
--gas-adjustment=1.2 \
--gas=auto
```
### WD
```
tacchaind tx distribution withdraw-rewards $(tacchaind keys show wallet --bech val -a) --commission --from wallet --chain-id tacchain_2391-1 --gas-prices=4000000000000utac --gas-adjustment=1.2 --gas=auto
```
### Delegate
```
tacchaind tx staking delegate $(tacchaind keys show wallet --bech val -a) 1000000000000000000utac --from wallet --chain-id tacchain_2391-1 --gas-prices=4000000000000utac --gas-adjustment=1.2 --gas=auto
```
### Own Peer
```
echo $(tacchaind tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.tacchaind/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Delete
```
sudo systemctl stop tacchainbd
sudo systemctl disable tacchaind
sudo rm /etc/systemd/system/tacchaind.service
sudo systemctl daemon-reload
rm -f $(which tacchaind)
rm -rf .tacchaind
rm -rf tacchain
```
