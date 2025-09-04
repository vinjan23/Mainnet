```
cd $HOME
git clone https://github.com/paxi-web3/paxi.git
cd paxi
git checkout v1.0.5
make install
```
```
cp ~/paxid/paxid ~/go/bin
```
```
paxid init Vinjan.Inc --chain-id paxi-mainnet
```
```
sed -i -e "s%:26657%:11757%"  ~/go/bin/paxi/config/client.toml
sed -i -e "s%:26658%:11758%; s%:26657%:11757%; s%:6060%:11760%; s%:26656%:11756%; s%:26660%:11761%"  ~/go/bin/paxi/config/config.toml
sed -i -e "s%:1317%:11717%; s%:9090%:11790%" ~/go/bin/paxi/config/app.toml
```

```
curl -Ls https://snapshot-t.vinjan.xyz/paxi/genesis.json > ~/go/bin/paxi/config/genesis.json
```

```
curl -Ls https://snapshot-t.vinjan.xyz/paxi/addrbook.json >~/go/bin/paxi/config/addrbook.json
```

```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.05upaxi\"/" ~/go/bin/paxi/config/app.toml

```
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" ~/go/bin/paxi/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" ~/go/bin/paxi/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"20\"/" ~/go/bin/paxi/config/app.toml
```
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" ~/go/bin/paxi/config/config.toml
```
```
sudo tee /etc/systemd/system/paxid.service > /dev/null <<EOF
[Unit]
Description=paxi
After=network-online.target
[Service]
User=$USER
ExecStart=$(which paxid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable paxid
sudo systemctl restart paxid
sudo journalctl -u paxid -f -o cat
```
```
paxid status 2>&1 | jq .sync_info
```
```
curl -L https://snapshot-t.vinjan.xyz/paxi/latest.tar.lz4  | lz4 -dc - | tar -xf - -C ~/go/bin/paxi
```
```
sudo systemctl stop paxid 
cp ~/go/bin/paxi/data/priv_validator_state.json ~/go/bin/paxi/priv_validator_state.json.backup
paxid tendermint unsafe-reset-all --home ~/go/bin/paxi --keep-addr-book

SNAP_RPC="https://mainnet-rpc.paxinet.io:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i "/\[statesync\]/, /^enable =/ s/=.*/= true/;\
/^rpc_servers =/ s|=.*|= \"$SNAP_RPC,$SNAP_RPC\"|;\
/^trust_height =/ s/=.*/= $BLOCK_HEIGHT/;\
/^trust_hash =/ s/=.*/= \"$TRUST_HASH\"/" ~/go/bin/paxi/config/config.toml

mv ~/go/bin/paxi/priv_validator_state.json.backup ~/go/bin/paxi/data/priv_validator_state.json
sudo systemctl restart paxid && sudo journalctl -u paxid -fo cat
```
```
paxid q bank balances $(paxid keys show wallet -a)
```
```
paxid tendermint show-validator
```
```
nano ~/go/bin/paxi/validator.json
```
```
{
  "pubkey":  ,
  "amount": "1000000upaxi",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.1",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
paxid tx staking create-validator ~/go/bin/paxi/validator.json \
--from wallet \
--chain-id paxi-mainnet \
--gas-prices=0.05upaxi \
--gas-adjustment=1.5 \
--gas=auto
```
```
paxid tx staking edit-validator \
--new-moniker "Vinjan.Inc" \
--identity "7C66E36EA2B71F68" \
--website "https://service.vinjan.xyz" \
--details "Staking Provider-IBC Relayer" \
--commission-rate "0.25" \
--from wallet \
--chain-id paxi-mainnet \
--fees 10000upaxi
```
```
paxid tx distribution withdraw-rewards $(paxid keys show wallet --bech val -a) --commission --from wallet --chain-id paxi-mainnet --fees 10000upaxi
```
```
paxid tx staking delegate $(paxid keys show wallet --bech val -a) 1000000upaxi --from wallet --chain-id paxi-mainnet --fees 10000upaxi
```
```
curl -sL https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Paxi/wasm |bash
```
```
paxi tx bank send wallet <TO_WALLET_ADDRESS> 1000000upaxi --from wallet --chain-id paxi-mainnet --fees 10000upaxi
```
```
sudo systemctl stop paxid
sudo systemctl disable paxid
rm /etc/systemd/system/paxid.service
sudo systemctl daemon-reload
rm -rf $(which paxid)
rm -rf paxi
rm -rf paxid
rm -rf  ~/go/bin/paxi
```

