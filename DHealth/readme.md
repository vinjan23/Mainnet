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
dhealthd init Vinjan.Inc --chain-id dhealth
```
```
wget -O $HOME/.dhealth/config/genesis.json "https://raw.githubusercontent.com/dhealthproject/mainnet/main/genesis.json"
```
```
wget -O $HOME/.dhealth/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/DHealth/addrbook.json"
```
```
peers="67243a0ed11567250aa02d5e47f6c4a0b8313975@142.93.174.93:26656,69d16d1147e90cdfb8ed066331a0abb9c71c3ae2@162.19.223.89:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.dhealth/config/config.toml
```
```
PORT=399
sed -i -e "s%:26657%:${PORT}57%" $HOME/.dhealth/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.dhealth/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.dhealth/config/app.toml
```

```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "2000"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
-e 's|^snapshot-interval *=.*|snapshot-interval = "2000"|' \
-e 's|^snapshot-keep-recent *=.*|snapshot-keep-recent = "5"|' \
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
SNAP_RPC="https://rpc-dhealth.vinjan.xyz:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.dhealth/config/config.toml
sudo systemctl restart dhealthd
sudo journalctl -u dhealthd -f -o cat
```
### Snapshot 815832
```
sudo apt install lz4 -y
sudo systemctl stop dhealthd
dhealthd tendermint unsafe-reset-all --home $HOME/.dhealth --keep-addr-book
curl -L https://snapshot.vinjan.xyz./dhealth/dhealth-snapshot-20240509.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.dhealth
sudo systemctl restart dhealthd
journalctl -fu dhealthd -o cat
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
```
dhealthd tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Stake Provider & IBC Relayer" \
--chain-id=dhealth \
--commission-rate="0.03" \
--from=wallet \
--gas=auto \
--gas-adjustment=1.5 \
--gas-prices="0.025udhp"
```
```
dhealthd tx slashing unjail --from wallet --chain-id dhealth --gas-adjustment=1.5 --gas=auto --gas-prices="0.025udhp"
```
```
dhealthd tx distribution withdraw-rewards $(dhealthd keys show wallet --bech val -a) --commission --from wallet --chain-id dhealth --gas-adjustment=1.5 --gas=auto --gas-prices="0.025udhp"
```
```
dhealthd tx staking delegate $(dhealthd keys show wallet --bech val -a) 1000000udhp --from wallet --chain-id dhealth --gas-adjustment=1.5 --gas=auto --gas-prices="0.025udhp"
```

```
sudo systemctl stop dhealthd
sudo systemctl disable dhealthd
sudo rm /etc/systemd/system/dhealthd.service
sudo systemctl daemon-reload
rm -f $(which dhealthd)
rm -rf .dhealth
rm -rf dhealth
```












