### Binary
```
cd $HOME
wget https://github.com/oxygene76/medasdigital-2/releases/download/v1.0.0/medasdigitald
chmod +x medasdigitald
mv medasdigitald $HOME/go/bin/
```
```
rm /usr/lib/libwasmvm.x86_64.so
wget -P /usr/lib https://github.com/CosmWasm/wasmvm/releases/download/v2.1.2/libwasmvm.x86_64.so
sudo ldconfig
```
```
mkdir -p $HOME/.medasdigital/cosmovisor/genesis/bin
cp $HOME/go/bin/medasdigitald $HOME/.medasdigital/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.medasdigital/cosmovisor/genesis $HOME/.medasdigital/cosmovisor/current -f
sudo ln -s $HOME/.medasdigital/cosmovisor/current/bin/medasdigitald /usr/local/bin/medasdigital -f
```
```
wget https://github.com/oxygene76/medasdigital-2/tree/main/binaries/v1.0.1/medasdigitald
chmod +x medasdigitald
mv medasdigitald $HOME/go/bin/
```
```
mkdir -p $HOME/.medasdigital/cosmovisor/upgrades/v1.0.1/bin
cp $HOME/go/bin/medasdigitald $HOME/.medasdigital/cosmovisor/upgrades/v1.0.1/bin/
```
### Init
```
medasdigitald init Vinjan.Inc --chain-id medasdigital-2
```
```
medasdigitald version --long | grep -e commit -e version
```
### Port
```
sed -i -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:23657\"%" $HOME/.medasdigital/config/client.toml
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:23658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:23657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:23060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:23656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":23660\"%" $HOME/.medasdigital/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:23317\"%; s%^address = \"localhost:9090\"%address = \"localhost:23090\"%" $HOME/.medasdigital/config/app.toml
```
```
PORT=123
sed -i -e "s|^chain-id *=.*|chain-id = \"medasdigital-2\"|" $HOME/.medasdigital/config/client.toml
sed -i -e "s%:26657%:${PORT}57%" $HOME/.medasdigital/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.medasdigital/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.medasdigital/config/app.toml
```
### Genesis
```
wget -O $HOME/.medasdigital/config/genesis.json https://raw.githubusercontent.com/oxygene76/medasdigital-2/refs/heads/main/genesis/mainnet/config/genesis.json
```
### Addrbook
```
wget -O $HOME/.medasdigital/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Medas/addrbook.json
``` 

### PEER
```
peers="0de13488933f37ced3ede6d78c4b9cabc845fbe5@65.21.234.111:23656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.medasdigital/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025umedas\"|" $HOME/.medasdigital/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.medasdigital/config/app.toml
```
### indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.medasdigital/config/config.toml
```
### service
```
sudo tee /etc/systemd/system/medasdigitald.service > /dev/null << EOF
[Unit]
Description=medasdigital
After=network-online.target
[Service]
User=$USER
ExecStart=$(which medasdigitald) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo tee /etc/systemd/system/medasdigitald.service > /dev/null << EOF
[Unit]
Description=medasdigital
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.medasdigital"
Environment="DAEMON_NAME=medasdigitald"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.medasdigital/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable medasdigitald
sudo systemctl restart medasdigitald
sudo journalctl -u medasdigitald -f -o cat
```
### Sync
```
medasdigitald status 2>&1 | jq .sync_info
```
### Wallet
```
medasdigitald keys add wallet
```
### Balances
```
medasdigitald  q bank balances $(medasdigitald keys show wallet -a)
```
### Validator
```
medasdigitald tendermint show-validator
```
```
nano /root/.medasdigital/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":""},
  "amount": "115000000umedas",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.05",
  "min-self-delegation": "1"
}
```
```
medasdigitald tx staking create-validator $HOME/.medasdigital/validator.json \
--from wallet \
--chain-id medasdigital-2 \
--gas-prices 0.025umedas \
--gas-adjustment 1.5 \
--gas auto
```
### Edit
```
medasdigitald tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--chain-id=medasdigital-2 \
--from=wallet \
--gas-prices 0.025umedas \
--gas-adjustment 1.5 \
--gas auto
```
### WD
```
medasdigitald tx distribution withdraw-rewards $(medasdigitald keys show wallet --bech val -a) --commission --from wallet --chain-id medasdigital-2 --gas-adjustment 1.5 --gas-prices 0.025umedas  --gas auto
```
### Stake
```
medasdigitald tx staking delegate $(medasdigitald keys show wallet --bech val -a) 1000000umedas --from wallet --chain-id medasdigital-2 --gas-adjustment 1.5 --gas-prices 0.025umedas  --gas auto
```
### Own
```
echo $(medasdigitald tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.medasdigital/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
```
sudo systemctl stop medasdigitald
cp $HOME/.medasdigital/data/priv_validator_state.json $HOME/.medasdigital/priv_validator_state.json.backup
medasdigitald tendermint unsafe-reset-all --home $HOME/.medasdigital --keep-addr-book
SNAP_RPC="https://rpc-medas.vinjan.xyz:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i "/\[statesync\]/, /^enable =/ s/=.*/= true/;\
/^rpc_servers =/ s|=.*|= \"$SNAP_RPC,$SNAP_RPC\"|;\
/^trust_height =/ s/=.*/= $BLOCK_HEIGHT/;\
/^trust_hash =/ s/=.*/= \"$TRUST_HASH\"/" $HOME/.medasdigital/config/config.toml
mv $HOME/.medasdigital/priv_validator_state.json.backup $HOME/.medasdigital/data/priv_validator_state.json
sudo systemctl restart medasdigitald && sudo journalctl -u medasdigitald -fo cat
```
### Delete
```
sudo systemctl stop medasdigitald
sudo systemctl disable medasdigitald
sudo rm /etc/systemd/system/medasdigitald.service
sudo systemctl daemon-reload
rm -f $(which medasdigitald)
rm -rf .medasdigital
rm -rf medasdigital
```




