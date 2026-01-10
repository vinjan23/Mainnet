### Go
```
ver="1.22.10"
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
rm -rf atomone
git clone https://github.com/atomone-hub/atomone
cd atomone
git checkout v1.1.2
make install
```
```
mkdir -p $HOME/.atomone/cosmovisor/genesis/bin
cp $HOME/go/bin/atomoned $HOME/.atomone/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.atomone/cosmovisor/genesis $HOME/.atomone/cosmovisor/current -f
sudo ln -s $HOME/.atomone/cosmovisor/current/bin/atomoned /usr/local/bin/atomoned -f
```
### Update
```
cd $HOME
rm -rf atomone
git clone https://github.com/atomone-hub/atomone.git
cd atomone
git checkout v3.0.3
make build
```
```
mkdir -p $HOME/.atomone/cosmovisor/upgrades/v3/bin
mv build/atomoned $HOME/.atomone/cosmovisor/upgrades/v3/bin/
rm -rf build
```
```
mkdir -p $HOME/.atomone/cosmovisor/upgrades/v3/bin
cp $HOME/go/bin/atomoned $HOME/.atomone/cosmovisor/upgrades/v3/bin/
```
```
$HOME/.atomone/cosmovisor/upgrades/v3/bin/atomoned version --long | grep -e commit -e version
```
```
atomoned version --long | grep -e commit -e version
```
### Init
```
atomoned init Vinjan.Inc --chain-id atomone-1
atomoned config chain-id atomone-1
atomoned config keyring-backend file
```
### Port
```
PORT=15
sed -i -e "s%:26657%:${PORT}657%" $HOME/.atomone/config/client.toml
sed -i -e "s%:26658%:${PORT}658%; s%:26657%:${PORT}657%; s%:6060%:${PORT}060%; s%:26656%:${PORT}656%; s%:26660%:${PORT}661%" $HOME/.atomone/config/config.toml
sed -i -e "s%:1317%:${PORT}317%; s%:8080%:${PORT}080%; s%:9090%:${PORT}090%; s%:9091%:${PORT}091%" $HOME/.atomone/config/app.toml
```

### Genesis
```
wget -O $HOME/.atomone/config/genesis.json  https://atomone.fra1.digitaloceanspaces.com/genesis.json
```
### Addrbook
```
wget -O $HOME/.atomone/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Atomone/addrbook.json
```

### Seed Peers
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.225uphoton\"|" $HOME/.atomone/config/app.toml
```

### Prunning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="20"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.atomone/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.atomone/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.atomone/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.atomone/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.atomone/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/atomoned.service > /dev/null << EOF
[Unit]
Description=atomone
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.atomone"
Environment="DAEMON_NAME=atomoned"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.atomone/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo tee /etc/systemd/system/atomoned.service > /dev/null <<EOF
[Unit]
Description=atomone
After=network-online.target

[Service]
User=$USER
ExecStart=$(which atomoned) start
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
sudo systemctl enable atomoned
```
```
sudo systemctl restart atomoned
```
```
sudo journalctl -u atomoned -f -o cat
```
### Sync
```
atomoned status 2>&1 | jq .SyncInfo
```
### Add wallet
```
atomoned keys add wallet --recover
```
### Balances
```
atomoned q bank balances $(atomoned keys show wallet -a)
```
### Validator
```
atomoned tx staking create-validator \
--amount=2000000000uatone \
--pubkey=$(atomoned tendermint show-validator) \
--moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Stake Provider & IBC Relayer" \
--chain-id=atomone-1 \
--commission-rate="0.02" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.02" \
--min-self-delegation=1 \
--from=wallet \
--gas=auto
```
### Edit
```
atomoned tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--details="Stake Provider & IBC Relayer" \
--chain-id=atomone-1 \
--from=wallet \
--gas-adjustment=1.2 \
--gas-prices="0.2uphoton" \
--gas=auto
```

### Delegate
```
atomoned tx staking delegate $(atomoned keys show wallet --bech val -a) 1000000uatone --from wallet --chain-id atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.1uphoton"
```
### WD Commission
```
atomoned tx distribution withdraw-rewards $(atomoned keys show wallet --bech val -a) --commission --from wallet --chain-id atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.1uphoton"
```
### Vote
```
atomoned tx gov vote 10 yes --from wallet --chain-id atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.1uphoton""
```

### Own Peer
```
echo $(atomoned tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.atomone/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
### Connect Peer
```
curl -sS http://localhost:15657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### Send
```
atomoned tx bank send wallet atone14m0n559xdj00qwvp6ck0xesprrq26kgp75j0zw 10000uatone --from=wallet --chain-id=atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.225uphoton""
```

### Delete
```
sudo systemctl stop atomoned
sudo systemctl disable atomoned
sudo rm /etc/systemd/system/atomoned.service
sudo systemctl daemon-reload
rm -f $(which atomoned)
rm -rf .atomone
rm -rf atomone
```




