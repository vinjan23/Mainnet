### Binary
```
cd $HOME
git clone https://github.com/sedaprotocol/seda-chain.git
cd seda-chain
git checkout v0.1.4
make install
```
#### update
```
cd $HOME
rm -rf seda-chain
git clone https://github.com/sedaprotocol/seda-chain.git
cd seda-chain
git checkout v0.1.10
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
`sha256sum $HOME/.althea/config/genesis.json`
`9893721bc5388d245cade09629ace75cd3648f8ebdb3a542b07e1b3f63cab6ba`

### Addrbook.json
```
wget -O $HOME/.sedad/config/addrbook.json https://snapshots.polkachu.com/addrbook/seda/addrbook.json --inet4-only
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
pruning_keep_every="2000"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sedad/config/app.toml
```
```
sed -i \
-e 's|^snapshot-interval *=.*|snapshot-interval = "2000"|' \
-e 's|^snapshot-keep-recent *=.*|snapshot-keep-recent = "5"|' \
$HOME/.sedad/config/app.toml
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
### Statesync
```
SNAP_RPC="https://seda-rpc.polkachu.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sedad/config/config.toml
sudo systemctl restart sedad
sudo journalctl -u sedad -f -o cat
```
### Snapshot 133346
```
sudo apt install lz4 -y
sudo systemctl stop sedad
sedad tendermint unsafe-reset-all --home $HOME/.sedad --keep-addr-book
curl -L https://snapshot.vinjan.xyz./seda/seda-snapshot-20240507.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.sedad
sudo systemctl restart sedad
journalctl -fu sedad -o cat
```

### Sync
```
sedad status 2>&1 | jq .sync_info
```
### Add Wallet
```
sedad keys add wallet --recover
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
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"EjBO6Jrc7CjGCHBG3KcniVaNHcsuVQKyWo8gm2qASTA="},
  "amount": "105000000000000000000aseda",
  "moniker": "vinjan",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.02",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.02",
  "min-self-delegation": "1"
}
```
```
sedad tx staking create-validator validator.json \
    --from=wallet \
    --chain-id=seda-1 \
    --fees=2000000000000000aseda
```
### Edit
```
sedad tx staking edit-validator \
--new-moniker="vinjan" \
--identity="7C66E36EA2B71F68" \
--details="Staking Provider-IBC Relayer" \
--website="" \
--chain-id=seda-1 \
--from=wallet \
--fees=2000000000000000aseda
```

### Unjail
```
sedad tx slashing unjail --from wallet --chain-id seda-1 --fees=20000000000aseda -y
```
### Delegate
```
sedad tx staking delegate $(sedad keys show wallet --bech val -a) 1000000000000000000aseda --from wallet --chain-id seda-1 --fees=2000000000000000aseda -y
```
### Withdraw Commission
```
sedad tx distribution withdraw-rewards $(sedad keys show wallet --bech val -a) --commission --from wallet --chain-id seda-1 --gas auto --gas-prices 10000000000aseda -y
```
### Withdraw
```
sedad tx distribution withdraw-all-rewards --from wallet --chain-id seda-1 --gas auto --gas-prices 10000000000aseda -y
```
### Redelegate
```
sedad tx staking redelegate $(sedad keys show wallet --bech val -a) <val_address> 1900000000000000000aseda --from wallet --chain-id seda-1 --gas-adjustment 1.4 --gas auto --gas-prices 10000000000aseda -y
```
### Cek Validator
```
[[ $(sedad q staking validator $(sedad keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(sedad status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Validator Info
```
sedad status 2>&1 | jq .validator_info
```
### Node Info
```
sedad status 2>&1 | jq .node_info
```

### Connected Peer
```
curl -sS http://localhost:11657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### Send 
```
sedad tx bank send wallet <TO_WALLET_ADDRESS> 1000000aseda --from wallet --chain-id seda-1 --fees=10000000000aseda -y
```
### Statesync
```
sudo systemctl stop sedad
sedad tendermint unsafe-reset-all --home $HOME/.sedad --keep-addr-book
SNAP_RPC="https://seda-rpc.polkachu.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sedad/config/config.toml
sudo systemctl restart sedad
sudo journalctl -u sedad -f -o cat
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



