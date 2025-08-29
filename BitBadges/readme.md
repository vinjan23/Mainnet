### Binary
```
cd $HOME
mkdir -p $HOME/.bitbadgeschain
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v12/bitbadgeschain-linux-amd64 -O /usr/local/bin/bitbadgeschaind
chmod +x /usr/local/bin/bitbadgeschaind
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/genesis/bin
cp /usr/local/bin/bitbadgeschaind $HOME/.bitbadgeschain/cosmovisor/genesis/bin/
```
```
cd $HOME
git clone https://github.com/BitBadges/bitbadgeschain.git
cd bitbadgeschain
git checkout v12
make build-linux/amd64
cp build/bitbadgeschain-linux-amd64 /usr/local/bin/bitbadgeschaind
chmod +x /usr/local/bin/bitbadgeschaind
```

```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin
cp $HOME/.bitbadgeschain/cosmovisor/genesis/bin/bitbadgeschaind $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin/
```
```
sudo ln -s $HOME/.bitbadgeschain/cosmovisor/genesis $HOME/.bitbadgeschain/cosmovisor/current -f
sudo ln -s $HOME/.bitbadgeschain/cosmovisor/current/bin/bitbadgeschaind /usr/local/bin/bitbadgeschaind -f
```
### Upgrade
```
cd $HOME
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v13/bitbadgeschain-linux-amd64 -O /usr/local/bin/bitbadgeschaind
chmod +x /usr/local/bin/bitbadgeschaind
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v13/bitbadgeschain-linux-amd64 -O $HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin/bitbadgeschaind
chmod +x $HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin/bitbadgeschaind
```
```
cd $HOME
rm -rf bitbadgeschain
git clone https://github.com/BitBadges/bitbadgeschain.git
cd bitbadgeschain
git checkout v13
make build-linux/amd64
cp build/bitbadgeschain-linux-amd64 /usr/local/bin/bitbadgeschaind
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin
cp /usr/local/bin/bitbadgeschaind $HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin/
chmod +x $HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin/bitbadgeschaind
```
```
$HOME/.bitbadgeschain/cosmovisor/upgrades/v13/bin/bitbadgeschaind version
```
```
bitbadgeschaind version --long | grep -e commit -e version
```
### Init
```
bitbadgeschaind init Vinjan.Inc --chain-id bitbadges-1
```
### Genesis
```
curl -L https://snap.vinjan.xyz/bitbadges/genesis.json > $HOME/.bitbadgeschain/config/genesis.json
```
### Addrbook
```
curl -L https://snap.vinjan.xyz/bitbadges/addrbook.json > $HOME/.bitbadgeschain/config/addrbook.json
```
### Port
```
PORT=135
sed -i -e "s%:26657%:${PORT}57%" $HOME/.bitbadgeschain/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.bitbadgeschain/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.bitbadgeschain/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.bitbadgeschain/config/app.toml
```
### Gas
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025ubadge\"/" $HOME/.bitbadgeschain/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.bitbadgeschain/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/bitbadgeschaind.service > /dev/null << EOF
[Unit]
Description=bitbadgeschain
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.bitbadgeschain"
Environment="DAEMON_NAME=bitbadgeschaind"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.bitbadgeschain/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable bitbadgeschaind
sudo systemctl restart bitbadgeschaind
sudo journalctl -u bitbadgeschaind -f -o cat
```
### Sync
```
bitbadgeschaind status 2>&1 | jq .sync_info
```
### Wallet
```
bitbadgeschaind keys add wallet
```
### Balances
```
bitbadgeschaind  q bank balances $(bitbadgeschaind keys show wallet -a)
```
### Validator
```
bitbadgeschaind tendermint show-validator
```
```
nano $HOME/.bitbadgeschain/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"MOq1jzGNmvThsrYjzlOTM8XGzzbqI9LwYZOH3RdN6J0="},
  "amount": "10000000000ubadge",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "0.5",
  "commission-max-change-rate": "0.5",
  "min-self-delegation": "1"
}
```
```
bitbadgeschaind tx staking create-validator $HOME/.bitbadgeschain/validator.json \
--from wallet \
--chain-id bitbadges-1 \
--gas-prices=0.00025ubadge \
--gas-adjustment=1.2 \
--gas=auto
```
```
bitbadgeschaind tx staking edit-validator \
--new-moniker="Vinjan.Inc | REStake" \
--identity="7C66E36EA2B71F68 " \
--website="https://service.vinjan.xyz" \
--details="Staking Provider-IBC Relayer" \
--chain-id=bitbadges-1 \
--from=wallet \
--fees 700000ubadge
```
```
bitbadgeschaind tx slashing unjail --from wallet --chain-id bitbadges-1 --fees 75000ubadge
```

### WD 
```
bitbadgeschaind tx distribution withdraw-rewards $(bitbadgeschaind keys show wallet --bech val -a) --commission --from wallet --chain-id bitbadges-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.00025ubadge"
```
### Stake
```
bitbadgeschaind tx staking delegate $(bitbadgeschaind keys show wallet --bech val -a) 1000000000ubadge --from wallet --chain-id bitbadges-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.00025ubadge"
```

### Delete
```
sudo systemctl stop bitbadgeschaind
sudo systemctl disable bitbadgeschaind
sudo rm /etc/systemd/system/bitbadgeschaind.service
sudo systemctl daemon-reload
rm -rf $(which bitbadgeschaind)
rm -rf .bitbadgeschain
```

