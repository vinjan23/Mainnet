```
git clone https://github.com/network-lumen/validator-kit.git
cd validator-kit
./join.sh Vinjan.Inc
cp /root/validator-kit/bin/lumend $HOME/go/bin
```
```
PORT=157
sed -i -e "s%:26657%:${PORT}57%" $HOME/.lumen/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.lumen/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.lumen/config/app.toml
```
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulmn\"/" $HOME/.lumen/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.lumen/config/config.toml
```
```
sudo tee /etc/systemd/system/lumend.service > /dev/null <<EOF
[Unit]
Description=lumen
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lumend) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable lumend
sudo systemctl restart lumend
sudo journalctl -u lumend -f -o cat
```
```
lumend status 2>&1 | jq .sync_info
```
```
lumend  q bank balances $(lumend keys show wallet -a)
```

### Get PQC public key
```
PQC_PUBKEY=$(lumend keys pqc-show node-pqc --keyring-backend test | grep "PubKey (hex)" | sed 's/.*: *//')
```
### Link PQC on-chain
```
lumend tx pqc link-account \
--from wallet \
--pubkey "$PQC_PUBKEY" \
--scheme dilithium3 \
--chain-id lumen \
--gas auto
```
```
lumend tendermint show-validator
```
```
nano $HOME/.lumen/validator.json
```
```
{
  "pubkey": ,
  "amount": "2000000ulmn",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
lumend tx staking create-validator $HOME/.lumen/validator.json \
--from wallet \
--chain-id lumen \
--pqc-key node-pqc \
--pqc-scheme dilithium3 \
--gas auto
```

### Vote
```
lumend tx gov vote 5 yes --from wallet --pqc-key node-pqc --chain-id lumen --gas auto
```
```
lumend tx staking delegate $(lumend keys show wallet --bech val -a) 1000000ulmn --from wallet --pqc-key node-pqc --chain-id lumen --gas auto
```
```
lumend tx distribution withdraw-rewards $(lumend keys show wallet --bech val -a) --commission --from wallet --pqc-key node-pqc --chain-id lumen --gas auto
```
```
lumend tx distribution withdraw-all-rewards --from wallet --pqc-key node-pqc --chain-id lumen --gas auto
```



