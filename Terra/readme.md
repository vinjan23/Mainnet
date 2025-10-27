```
cd $HOME
rm -rf core
git clone https://github.com/classic-terra/core.git
cd core
git checkout v3.6.0
make install
```
```
mkdir -p $HOME/.terra/cosmovisor/genesis/bin
cp $HOME/go/bin/terrad $HOME/.terra/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.terra/cosmovisor/genesis $HOME/.terra/cosmovisor/current -f
sudo ln -s $HOME/.terra/cosmovisor/current/bin/terrad /usr/local/bin/terrad -f
```
```
terrad version --long | grep -e commit -e version
```
```
terrad init Vinjan.Inc --chain-id columbus-5
```
```
curl -L https://snapshot-t.vinjan.xyz/terra/genesis.json > $HOME/.terra/config/genesis.json
```
```
curl -L https://snapshot-t.vinjan.xyz/terra/addrbook.json > $HOME/.terra/config/addrbook.json
```
```
PORT=175
sed -i -e "s%:26657%:${PORT}57%" $HOME/.terra/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.terra/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:8080%:${PORT}80%; s%:9090%:${PORT}90%; s%:9091%:${PORT}91%" $HOME/.terra/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "10"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "10"|' \
$HOME/.terra/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.terra/config/config.toml
```
```
sudo tee /etc/systemd/system/terrad.service > /dev/null << EOF
[Unit]
Description=terra
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.terra"
Environment="DAEMON_NAME=terrad"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.terra/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable terrad
sudo systemctl restart terrad
sudo journalctl -u terrad -f -o cat
```
```
terrad status 2>&1 | jq .SyncInfo
```
```
sudo systemctl stop terrad
terrad tendermint unsafe-reset-all --home $HOME/.terra --keep-addr-book
```
```
curl -L https://snapshots.publicnode.com/terra-classic-pruned-25705098-25705108.tar.lz4  | lz4 -dc - | tar -xf - -C $HOME/.terra
```
```
curl -L https://snapshot-t.vinjan.xyz/terra/latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.terra
```
```
terrad q bank balances $(terrad keys show wallet -a)
```
```
terrad tx staking create-validator \
--amount=30000000000uluna \
--pubkey=$(terrad tendermint show-validator) \
--moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Stake Provider & IBC Relayer" \
--chain-id=columbus-5 \
--commission-rate="0.1" \
--commission-max-rate="0.5" \
--commission-max-change-rate="0.5" \
--min-self-delegation=1 \
--from=wallet \
--fees 200000000uluna \
--gas=300000
```
