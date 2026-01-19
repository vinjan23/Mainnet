```
cd $HOME
rm -rf kiichain
git clone https://github.com/KiiChain/kiichain.git
cd kiichain
git checkout v6.1.0
make install
```
```
mkdir -p $HOME/.kiichain/cosmovisor/genesis/bin
cp $HOME/go/bin/kiichaind $HOME/.kiichain/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.kiichain/cosmovisor/genesis $HOME/.kiichain/cosmovisor/current -f
sudo ln -s $HOME/.kiichain/cosmovisor/current/bin/kiichaind /usr/local/bin/kiichaind -f
```
```
kiichaind version --long | grep -e commit -e version
```
```
kiichaind init Vinjan.Inc --chain-id kiichain_1783-1
```
```
wget -O $HOME/.kiichain/config/genesis.json https://raw.githubusercontent.com/KiiChain/mainnets/refs/heads/main/kiichain/genesis.json
```
```
PORT=199
sed -i -e "s%:26657%:${PORT}57%" $HOME/.kiichain/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.kiichain/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.kiichain/config/app.toml
```
```
persistent_peers="$(curl -sS https://rpc-kiichain.vinjan-inc.com:443/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$persistent_peers\"/" $HOME/.kiichain/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"333333333akii\"/" $HOME/.kiichain/config/app.toml
sed -i -e "/evm-chain-id =/ s/= .*/= 1783/" $HOME/.kiichain/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.kiichain/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.kiichain/config/config.toml
```
```
sudo tee /etc/systemd/system/kiichaind.service > /dev/null << EOF
[Unit]
Description=kiichain
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.kiichain"
Environment="DAEMON_NAME=kiichaind"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.kiichain/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable kiichaind
sudo systemctl restart kiichaind
sudo journalctl -u kiichaind -f -o cat
```
```
sudo systemctl stop kiichaind
kiichaind comet unsafe-reset-all --home $HOME/.kiichain --keep-addr-book
cp $HOME/.kiichaindata/priv_validator_state.json $HOME/.kiichain/priv_validator_state.json.backup
SNAP_RPC="https://rpc-kiichain.vinjan-inc.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i "/\[statesync\]/, /^enable =/ s/=.*/= true/;\
/^rpc_servers =/ s|=.*|= \"$SNAP_RPC,$SNAP_RPC\"|;\
/^trust_height =/ s/=.*/= $BLOCK_HEIGHT/;\
/^trust_hash =/ s/=.*/= \"$TRUST_HASH\"/" $HOME/.kiichain/config/config.toml
mv $HOME/.kiichain/priv_validator_state.json.backup $HOME/.kiichain/data/priv_validator_state.json
sudo systemctl restart kiichaind && sudo journalctl -u kiichaind -fo cat
```
```
kiichaind status 2>&1 | jq .sync_info
```
```
kiichaind keys add wallet
```
```
kiichaind q bank balances $(kiichaind keys show wallet -a)
```
```
kiichaind comet show-validator
```
```
nano $HOME/.kiichain/validator.json
```
```
{
  "pubkey": ,
  "amount": "9900000000000000000akii",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
kiichaind tx staking create-validator $HOME/.kiichain/validator.json \
--from wallet \
--chain-id kiichain_1783-1 \
--gas-prices="333333333akii" \
--gas-adjustment=1.2 \
--gas=auto
```



```
sudo systemctl stop kiichaind
sudo systemctl disable kiichaind
sudo rm /etc/systemd/system/kiichaind.service
sudo systemctl daemon-reload
rm -rf $(which kiichaind)
rm -rf .kiichain
rm -rf kiichain
```

