```
sudo curl https://get.ignite.com/cli | sudo bash
```
```
sudo mv ignite /usr/local/bin/
```
```
cd $HOME
git clone https://github.com/dhealthproject/dhealth.git
cd dhealth
git checkout v1.0.0
ignite chain build
```
```
dhealthd version --long
```

```
dhealthd init Vinjan.Inc --chain-id dhealth --recover
```
```
wget -O $HOME/.dhealth/config/genesis.json "https://raw.githubusercontent.com/dhealthproject/mainnet/main/genesis.json"
```
```
peers="67243a0ed11567250aa02d5e47f6c4a0b8313975@142.93.174.93:26656,69d16d1147e90cdfb8ed066331a0abb9c71c3ae2@162.19.223.89:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.dhealth/config/config.toml
```
```
PORT=39
dhealthd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.dhealth/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%; s%^address = \"127.0.0.1:8545\"%address = \"127.0.0.1:${PORT}545\"%; s%^ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:${PORT}546\"%" $HOME/.dhealth/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.dhealth/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.dhealth/config/config.toml
```
```
sudo tee /etc/systemd/system/dhealthd.service > /dev/null <<EOF
[Unit]
Description=dhealth
After=network-online.target

[Service]
User=$USER
ExecStart=$(which dhealthd) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable dhealthd
sudo systemctl restart dhealthd
sudo journalctl -u dhealthd -f -o cat
```
```
SNAP_RPC="https://rpc.dhealth.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
# BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - LATEST_HEIGHT % 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.dhealth/config/config.toml
more ~/.dhealth/config/config.toml | grep 'rpc_servers'
more ~/.dhealth/config/config.toml | grep 'trust_height'
more ~/.dhealth/config/config.toml | grep 'trust_hash'
```

```
dhealthd status 2>&1 | jq .SyncInfo
```
```
dhealthd keys add wallet --recover
```
```
dhealthd keys unsafe-export-eth-key wallet
```
```
dhealthd q bank balances $(dhealthd keys show wallet -a)
```
```
dhealthd keys convert-bech32-to-hex $(dhealthd keys show wallet -a)
```
```
dhealthd tx staking create-validator \
--amount=2000000000udhp \
--pubkey=$(dhealthd tendermint show-validator) \
--moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Stake Provider & IBC Relayer" \
--chain-id=dhealth \
--commission-rate="0.05" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.02" \
--min-self-delegation=1 \
--from=wallet \
--gas=auto \
--gas-adjustment=1.5 \
--gas-prices="0.025udhp"
```











