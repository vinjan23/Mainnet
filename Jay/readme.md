
### Binary
```
cd $HOME
rm -rf thejaynetwork
git clone https://github.com/bbtccore/thejaynetwork.git
cd thejaynetwork
git checkout v1.1.0
make install
```
```
mkdir -p $HOME/.jayn/cosmovisor/genesis/bin
cp $HOME/go/bin/jaynd $HOME/.jayn/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.jayn/cosmovisor/genesis $HOME/.jayn/cosmovisor/current -f
sudo ln -s $HOME/.jayn/cosmovisor/current/bin/jaynd /usr/local/bin/jaynd -f
```
### Init
```
jaynd init Vinjan.Inc --chain-id thejaynetwork
```
### PORT
```
PORT=182
sed -i -e "s%:26657%:${PORT}57%" $HOME/.jayn/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.jayn/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.jayn/config/app.toml
```
### Genesis
```
curl -s http://89.58.25.104:26657/genesis | jq '.result.genesis' > ~/.jayn/config/genesis.json
```
### peer
```
peers="218942ae4b1d1d8ab6517b06e0828198a0867bb1@peer-jayn.vinjan-inc.com:18256,ba900c17cfcc187e374323ff31016b178d088d55@89.58.24.232:26656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.jayn/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025ujay\"|" $HOME/.jayn/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.jayn/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.jayn/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/jaynd.service > /dev/null << EOF
[Unit]
Description=jay
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.jayn"
Environment="DAEMON_NAME=jaynd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.jaynd/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable jaynd
sudo systemctl restart jaynd
sudo journalctl -u jaynd -f -o cat
```
### Sync
```
jaynd status 2>&1 | jq .sync_info
```

### Statesync
```
sudo systemctl stop jaynd
SNAP_RPC="http://89.58.25.104:26657"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i "/\[statesync\]/, /^enable =/ s/=.*/= true/;\
/^rpc_servers =/ s|=.*|= \"$SNAP_RPC,$SNAP_RPC\"|;\
/^trust_height =/ s/=.*/= $BLOCK_HEIGHT/;\
/^trust_hash =/ s/=.*/= \"$TRUST_HASH\"/" $HOME/.jayn/config/config.toml

```
### Wallet
```
jaynd keys add wallet
```
```
jaynd q bank balances $(jaynd keys show wallet -a)
```
```
jaynd comet show-validator
```
```
nano $HOME/.jayn/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"GPD4dSVaMLG6+qkvuWlSbeWdjznAIaCbp7ZUDbGWzt4="},
  "amount": "4000000000ujay",
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
jaynd tx staking create-validator $HOME/.jayn/validator.json \
--from wallet \
--chain-id thejaynetwork \
--gas-prices="0.01ujay" \
--gas-adjustment=1.5 \
--gas=auto
```
```
jaynd tx staking edit-validator \
--new-moniker="Vinjan.Inc | REStake" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--details="Staking Provider-IBC Relayer | https://restake.app/thejaynetwork/yjayvaloper1zuv7m0jy4hrxyk4xxw65wfxu7mf0dywnc9y2en" \
--chain-id thejaynetwork \
--from=wallet \
--gas-prices="0.025ujay" \
--gas-adjustment=1.5 \
--gas=auto
```
```
jayndd tx staking delegate $(jaynd keys show wallet --bech val -a) 1000000ujay --from wallet --chain-id thejaynetwork --gas-adjustment=1.5 --gas=auto --gas-prices="0.01ujay"
```
```
jaynd tx distribution withdraw-rewards $(jaynd keys show wallet --bech val -a) --from wallet --chain-id thejaynetwork --gas-adjustment=1.5 --gas=auto --gas-prices="0.01ujay"
```
```
echo $(jaynd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.jayn/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
### Delete
```
sudo systemctl stop jaynd
sudo systemctl disable jaynd
sudo rm /etc/systemd/system/jaynd.service
sudo systemctl daemon-reload
rm -rf $(which jaynd)
rm -rf $HOME/.jayn
rm -rf $HOME/thejaynetwork
```

