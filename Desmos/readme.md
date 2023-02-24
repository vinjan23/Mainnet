###
```
cd $HOME
git clone https://github.com/desmos-labs/desmos.git
cd desmos
git checkout v4.7.0
make install
```

```
MONIKER=
```

```
PORT=43
desmos init $MONIKER --chain-id desmos-mainnet
desmos config chain-id desmos-mainnet
desmos config keyring-backend file
desmos config node tcp://localhost:${PORT}657
```

```
curl -s https://raw.githubusercontent.com/desmos-labs/mainnet/main/genesis.json > $HOME/.desmos/config/genesis.json
curl -s https://snapshots1.nodejumper.io/desmos/addrbook.json > $HOME/.desmos/config/addrbook.json
```

```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.desmos/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.desmos/config/app.toml
```

```
sudo tee /etc/systemd/system/desmos.service > /dev/null <<EOF
[Unit]
Description=desmos mainnet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which desmos) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

```
sudo systemctl daemon-reload
sudo systemctl enable desmos
sudo systemctl restart desmos
sudo journalctl -fu desmos -o cat
```
```
peers="d2b9e735329a1addb7090b1509bc018eea32d691@desmos.statesync.nodersteam.com:23656"
sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.desmos/config/config.toml

SNAP_RPC=http://desmos.statesync.nodersteam.com:23657

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.desmos/config/config.toml

sudo systemctl restart desmosd
desmos tendermint unsafe-reset-all --home /root/.desmos --keep-addr-book

sudo systemctl restart desmos && journalctl -u desmos -f -o cat
```


```
desmos status 2>&1 | jq .SyncInfo
```

```
desmos keys add wallet --recover
```

```
desmos keys list
```

```
desmos q bank balances desmos1a59zedna28qj6p0yx3x9fxu920ffx3m7dfr8ju
```

```
desmos tx staking create-validator \
--amount=557000000udsm \
--pubkey=$(desmos tendermint show-validator) \
--moniker="vinjan" \
--identity=7C66E36EA2B71F68 \
--website=https://nodes.vinjan.xyz \
--details="https://explorer.vinjan.xyz" \
--chain-id=desmos-mainnet \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-prices=0.1udsm \
--gas-adjustment=1.5 \
--gas=auto \
-y
```
```
desmos tx staking edit-validator \
--new-moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL"
--chain-id=desmos-mainnet \
--from=<WALLET> \
--fees 200udsm \
-y
```
```
desmos tx slashing unjail --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```

```
desmos tx staking delegate <validator> 1000000udsm --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
```
desmos tx distribution withdraw-all-rewards --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
```
desmos tx distribution withdraw-rewards <VALOPER> --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
### Unbond/Unstake
```
desmos tx staking unbond $(desmos keys show <WALLET> --bech val -a) 1000000udsm --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```

### Transfer
```
desmos tx bank send <WALLET> <TO_WALLET_ADDRESS> 1000000udsm --from <WALLET> --fees 200udsm --chain-id desmos-mainnet
```
### Validator Info
```
desmos status 2>&1 | jq .ValidatorInfo
```

### Check Validator match with wallet
```
[[ $(desmos q staking validator $(desmos keys show <WALLET> --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(desmos status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Stop 
```
sudo systemctl stop desmos
```
### Restart
```
sudo systemctl restart desmos
```

### Delete Node
```
cd $HOME
sudo systemctl stop desmos
sudo systemctl disable desmos
sudo rm /etc/systemd/system/desmos.service
sudo systemctl daemon-reload
rm -rf $(which desmos) 
rm -rf $HOME/.desmos
rm -rf $HOME/rebus.core
```










