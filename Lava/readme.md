### Binary
```
cd $HOME
rm -rf lava
git clone https://github.com/lavanet/lava
cd lava
git checkout v5.3.0
make install-all
```
```
mkdir -p $HOME/.lava/cosmovisor/genesis/bin
cp $HOME/go/bin/lavad $HOME/.lava/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.lava/cosmovisor/genesis $HOME/.lava/cosmovisor/current -f
sudo ln -s $HOME/.lava/cosmovisor/current/bin/lavad /usr/local/bin/lavad -f
```
```
mkdir -p $HOME/.lava/cosmovisor/upgrades/v5.3.0/bin
cp $HOME/go/bin/lavad $HOME/.lava/cosmovisor/upgrades/v5.3.0/bin/
```
### Update
```
cd $HOME
rm -rf lava
git clone https://github.com/lavanet/lava.git
cd lava
git checkout v5.5.1
make install-all
```
```
mkdir -p $HOME/.lava/cosmovisor/upgrades/v5.5.1/bin
cp $HOME/go/bin/lavad $HOME/.lava/cosmovisor/upgrades/v5.5.1/bin/
```
```
cd $HOME
wget -O lavad https://github.com/lavanet/lava/releases/download/v5.5.1/lavad-v5.5.1-linux-amd64
chmod +x lavad
mkdir -p $HOME/.lava/cosmovisor/upgrades/v5.5.1/bin
mv lavad $HOME/.lava/cosmovisor/upgrades/v5.5.1/bin/
```
```
$HOME/.lava/cosmovisor/upgrades/v5.5.1/bin/lavad version --long | grep -e commit -e version
```
```
lavad version --long | grep -e commit -e version
```
```
lavad init Vinjan.Inc --chain-id lava-mainnet-1
```
```
PORT=299
sed -i -e "s%:26657%:${PORT}57%" $HOME/.lava/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.lava/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:8080%:${PORT}80%; s%:9090%:${PORT}90%; s%:9091%:${PORT}91%" $HOME/.lava/config/app.toml
```
```
curl -L https://snap.vinjan.xyz/lava/genesis.json > $HOME/.lava/config/genesis.json
```
```
curl -L https://snap.vinjan.xyz/lava/addrbook.json > $HOME/.lava/config/addrbook.json
```
```
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
  $HOME/.lava/config/app.toml
```
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.0025ulava"|g' $HOME/.lava/config/app.toml
```
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.lava/config/config.toml
```
```
sudo tee /etc/systemd/system/lavad.service > /dev/null << EOF
[Unit]
Description=lava
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.lava"
Environment="DAEMON_NAME=lavad"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.lava/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl restart lavad
sudo journalctl -u lavad -f -o cat
```
```
lavad  status 2>&1 | jq .SyncInfo
```
```
lavad q bank balances $(lavad keys show wallet -a) 
```
```
lavad tx staking create-validator \
--amount=9000000ulava \
--pubkey=$(lavad tendermint show-validator) \
--moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="IBC Relayer Operator" \
--chain-id=lava-mainnet-1 \
--commission-rate="0.01" \
--commission-max-rate="1" \
--commission-max-change-rate="1" \
--min-self-delegation=1 \
--from=wallet \
--gas-adjustment=1.5 \
--gas-prices="0.0025ulava" \
--gas=auto
```
```
lavad tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--details="IBC Relayer Operator" \
--chain-id=lava-mainnet-1 \
--commission-rate="0.05" \
--from=wallet \
--gas-adjustment=1.5 \
--gas-prices="0.0025ulava" \
--gas=auto
```
```
lavad tx distribution withdraw-rewards $(lavad keys show wallet --bech val -a) --commission --from wallet --chain-id lava-mainnet-1 --gas-prices=0.0025ulava --gas-adjustment=1.5 --gas=auto
```
```
lavad tx staking delegate $(lavad keys show wallet --bech val -a) 1000000ulava --from wallet --chain-id lava-mainnet-1 --gas-prices=0.0025ulava --gas-adjustment=1.5 --gas=auto
```
```
curl -L https://snap.vinjan.xyz/lava/latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.lava
```
```
sudo systemctl stop lavad
sudo systemctl disable lavad
sudo rm /etc/systemd/system/lavad.service
sudo systemctl daemon-reload
rm -f $(which lavad)
rm -rf .lava
rm -rf lava
```
