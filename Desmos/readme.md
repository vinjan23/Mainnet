###
```
cd || return
rm -rf desmos
git clone https://github.com/desmos-labs/desmos.git
cd desmos || return
git checkout v4.7.0
make install
desmos version # 4.7.0
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
sudo tee /etc/systemd/system/desmosd.service > /dev/null << EOF
[Unit]
Description=Desmos Node
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
desmos tendermint unsafe-reset-all --home $HOME/.desmos --keep-addr-book

SNAP_RPC="https://desmos.nodejumper.io:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i 's|^enable *=.*|enable = true|' $HOME/.desmos/config/config.toml
sed -i 's|^rpc_servers *=.*|rpc_servers = "'$SNAP_RPC,$SNAP_RPC'"|' $HOME/.desmos/config/config.toml
sed -i 's|^trust_height *=.*|trust_height = '$BLOCK_HEIGHT'|' $HOME/.desmos/config/config.toml
sed -i 's|^trust_hash *=.*|trust_hash = "'$TRUST_HASH'"|' $HOME/.desmos/config/config.toml
```

```
sudo systemctl daemon-reload
sudo systemctl enable desmosd
sudo systemctl restart desmosd
sudo journalctl -fu desmosd -o cat
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





