### Binary
```
cd $HOME
git clone https://github.com/sedaprotocol/seda-chain.git
cd seda-chain
git checkout v0.1.1
make install
```
### Init
```
MONIKER=
```
```
sedad init $MONIKER --chain-id seda-1
```
### Port 11
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:11657\"%" $HOME/.sedad/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:11658\"%; s%^laddr = \"tcp://0.0.0.0:26657\"%laddr = \"tcp://0.0.0.0:11657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:11060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:11656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":11660\"%" $HOME/.sedad/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:11317\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:11090\"%" $HOME/.sedad/config/app.toml
```
### Genesis
```
wget -O $HOME/.sedad/config/genesis.json "https://raw.githubusercontent.com/sedaprotocol/seda-networks/main/mainnet/genesis.json"
```

### Seed Peer Gas
```
seeds="31f54fbcf445a9d9286426be59a17a811dd63f84@18.133.231.208:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.sedad/config/config.toml
peers="770ff46af89cd0ca4f6cd7bc532648826f7995f5@62.169.30.154:26656,58c919e7b89b8c5b5a3024f5e7cec07d2e3b28d3@78.47.163.48:26656,8d887e7007696439a955e839d786532af746f697@94.130.13.186:25856,d4b0af2651d980d1a12267b8b936689120f39aef@195.201.10.252:17356,fc319e170aea3e99c75eb411505bd0a6d938b4e2@109.199.127.16:25856"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.sedad/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"10000000000aseda\"|" $HOME/.sedad/config/app.toml
```
### Prunning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sedad/config/app.toml
```
### Indexer Off
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sedad/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/sedad.service > /dev/null <<EOF
[Unit]
Description=seda
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sedad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable sedad
sudo systemctl restart sedad
sudo journalctl -u sedad -f -o cat
```
### Sync
```
wardend status 2>&1 | jq .sync_info
```
### Add Wallet
```
sedad keys add wallet
```
### Balances
```
sedad q bank balances $(sedad keys show wallet -a)
```

### Create Validator

- Check Pubkey
```
sedad comet show-validator
```
- Make File validator.json
```
nano $HOME/validator.json
```
```
{
  "pubkey": {"#pubkey"},
  "amount": "1000000000000000000aseda",
  "moniker": "",
  "identity": "",
  "website": "",
  "security": "",
  "details": "",
  "commission-rate": "0.05",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.2",
  "min-self-delegation": "1"
}
```
```
sedad tx staking create-validator validator.json \
    --from=wallet \
    --chain-id=seda-1 \
    --fees=10000000000aseda
```
### Unjail
```
sedad tx slashing unjail --from wallet --chain-id seda-1 --fees=10000000000aseda -y
```
### Delegate
```
sedad tx staking delegate $(sedad keys show wallet --bech val -a) 1000000aseda --from wallet --chain-id seda-1 --fees=10000000000aseda -y
```
### Withdraw Commission
```
sedad tx distribution withdraw-rewards $(sedad keys show wallet --bech val -a) --commission --from wallet --chain-id seda-1 --fees=10000000000aseda -y
```
### Withdraw
```
sedad tx distribution withdraw-all-rewards --from wallet --chain-id seda-1 --fees=10000000000aseda -y
```
### Connected Peer
```
curl -sS http://localhost:11657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### Send 
```
sedad tx bank send wallet <TO_WALLET_ADDRESS> 1000000aseda --from wallet --chain-id seda-1 --fees=10000000000aseda -y
```

### Delete
```
cd $HOME
sudo systemctl stop sedad
sudo systemctl disable sedad
sudo rm /etc/systemd/system/sedad.service
sudo systemctl daemon-reload
rm -f $(which sedad)
rm -rf $HOME/.sedad
rm -rf $HOME/seda-chain
```


