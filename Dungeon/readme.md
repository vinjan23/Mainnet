### Binary
```
cd $HOME
rm -rf dungeonchain 
git clone https://github.com/Crypto-Dungeon/dungeonchain.git
cd dungeonchain
git checkout v5.0.0
make install
```
```
mkdir -p $HOME/.dungeonchain/cosmovisor/genesis/bin
cp $HOME/go/bin/dungeond $HOME/.dungeonchain/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.dungeonchain/cosmovisor/genesis $HOME/.dungeonchain/cosmovisor/current -f
sudo ln -s $HOME/.dungeonchain/cosmovisor/current/bin/dungeond /usr/local/bin/dungeond -f
```
### Init
```
dungeond init <node_name> --chain-id dungeon-1
```

### Custom Port
```
PORT=165
sed -i -e "s%:26657%:${PORT}57%" $HOME/.dungeonchain/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.dungeonchain/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.dungeonchain/config/app.toml
```

### Genesis
```

```

### Addrbook
```

```

### Seed Peer Gas
```
peers="f174206d6b3dbc2dd17cdd884bdfc6ad37268a09@67.218.8.88:26665,5545dc6fa6537ce464a49593bac02258fd963e57@67.218.8.88:26665,cd2311ffdae014daff80c343c26a393e714c7973@172.31.23.120:26656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.dungeonchain/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0udgn\"|" $HOME/.dungeonchain/config/app.toml
```


### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.dungeonchain/config/app.toml
```

### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.dungeonchain/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/dungeond.service > /dev/null << EOF
[Unit]
Description=dungeon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.dungeonchain"
Environment="DAEMON_NAME=dungeond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.dungeonchain/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable dungeond
sudo systemctl restart dungeond
sudo journalctl -u dungeond -f -o cat
```

### Sync
```
dungeond status 2>&1 | jq .sync_info
```
### Log
```
sudo journalctl -u empowerd -f -o cat
```

### Wallet
```
empowerd keys add wallet
```
### Recover
```
empowerd keys add wallet --recover
```

### Balances
```
empowerd q bank balances $(empowerd keys show wallet -a)
```

### Validator
```
empowerd tx staking create-validator \
--amount 1000000umpwr \
--chain-id empowerchain-1 \
--commission-max-change-rate 0.1 \
--commission-max-rate 0.2 \
--commission-rate 0.05 \
--min-self-delegation "1" \
--moniker "vinjan" \
--details="🎉Proffesional Stake & Node Validator🎉" \
--website "https://service.vinjan.xyz" \
--security-contact="<validator-security-contact>" \
--identity="7C66E36EA2B71F68" \
--from wallet \
--pubkey=$(empowerd tendermint show-validator) \
--gas-adjustment=1.5 \
--gas=auto 
```

### Edit
```
empowerd tx staking edit-validator \
--new-moniker ""  \
--chain-id empowerchain-1 \
--details "" \
--identity "" \
--from "" \
--gas-prices 0.025umpwr
```
### Unjail
```
empowerd tx slashing unjail --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```
### Jail reason
```
empowerd query slashing signing-info $(empowerd tendermint show-validator)
```

### Delegate
```
empowerd tx staking delegate $(empowerd keys show wallet --bech val -a) 900000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```
### Delegate to Another Validator
```
empowerd tx staking redelegate $(empowerd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 1000000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```

### Withdraw
```
empowerd tx distribution withdraw-all-rewards --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```
### Withdraw with Commission
```
empowerd tx distribution withdraw-rewards $(empowerd keys show wallet --bech val -a) --commission --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```

### Transfer
```
empowerd tx bank send wallet <TO_WALLET_ADDRESS> 1000000umpwr --from wallet --chain-id empowerchain-1
```

### Vote 
```
empowerd tx gov vote 1 yes --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```

### Check Matches
```
[[ $(empowerd q staking validator $(empowerd keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(empowerd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Own Peer
```
echo $(empowerd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.empowerd/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Stop
```
sudo systemctl stop empowerd
```
### Restart
```
sudo systemctl restart empowerd
```
### Node Info
```
empowerd status 2>&1 | jq .NodeInfo
```
### Validator Info
```
empowerd status 2>&1 | jq .ValidatorInfo
```

### Delete
```
sudo systemctl stop empowerd
sudo systemctl disable empowerd
sudo rm /etc/systemd/system/empowerd.service
sudo systemctl daemon-reload
rm -f $(which empowerd)
rm -rf $HOME/.empowerchain
rm -rf $HOME/empowerchain
```


