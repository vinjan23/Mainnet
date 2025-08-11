### Binary
```
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v11/bitbadgeschain-linux-amd64
mv bitbadgeschain-linux-amd64 $HOME/go/bin/bitbadgeschaind
chmod +x $HOME/go/bin/bitbadgeschaind
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/genesis/bin
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v11/bitbadgeschain-linux-amd64 -O $HOME/.bitbadgeschain/cosmovisor/genesis/bin/bitbadgeschaind
chmod +x $HOME/.bitbadgeschain/cosmovisor/genesis/bin/bitbadgeschaind
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/genesis/bin
cp $HOME/go/bin/bitbadgeschaind $HOME/.bitbadgeschain/cosmovisor/genesis/bin/
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/upgrades/v11/bin
cp $HOME/go/bin/bitbadgeschaind $HOME/.bitbadgeschain/cosmovisor/upgrades/v11/bin/
```
```
sudo ln -s $HOME/.bitbadgeschain/cosmovisor/genesis $HOME/.bitbadgeschain/cosmovisor/current -f
sudo ln -s $HOME/.bitbadgeschain/cosmovisor/current/bin/bitbadgeschaind /usr/local/bin/bitbadgeschaind -f
```
### Upgrade
```
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v12/bitbadgeschain-linux-amd64
mv bitbadgeschain-linux-amd64 $HOME/go/bin/bitbadgeschaind
chmod +x $HOME/go/bin/bitbadgeschaind
```
```
mkdir -p $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin
mv $HOME/go/bin/bitbadgeschaind $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin/
```
```
cd $HOME
mkdir -p $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin
wget https://github.com/BitBadges/bitbadgeschain/releases/download/v12/bitbadgeschain-linux-amd64 -O $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin/bitbadgeschaind
chmod +x $HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin/bitbadgeschaind
```
```
$HOME/.bitbadgeschain/cosmovisor/upgrades/v12/bin/bitbadgeschaind version --long | grep -e commit -e version
```
```
bitbadgeschaind version --long | grep -e commit -e version
```
```
bitbadgeschaind init Vinjan.Inc --chain-id bitbadges-1
```
```
PORT=135
sed -i -e "s%:26657%:${PORT}57%" $HOME/.bitbadgeschain/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.bitbadgeschain/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.bitbadgeschain/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "10"|' \
$HOME/.bitbadgeschain/config/app.toml
```
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ubadge\"/" $HOME/.bitbadgeschain/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.bitbadgeschain/config/config.toml
```
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
```
sudo systemctl daemon-reload
sudo systemctl enable bitbadgeschaind
sudo systemctl restart bitbadgeschaind
sudo journalctl -u bitbadgeschaind -f -o cat
```
```
bitbadgeschaind status 2>&1 | jq .sync_info
```
```
bitbadgeschaind keys add wallet
```
```
bitbadgeschaind  q bank balances $(bitbadgeschaind keys show wallet -a)
```
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
--gas-prices=0.025ubadge \
--gas-adjustment=1.2 \
--gas=auto
```

