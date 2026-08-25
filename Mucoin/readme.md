```
cd $HOME
rm -rf mucoin
git clone https://github.com/dasgrid/mucoin.git
cd mucoin
git checkout rewards-v0.8.0
make install
```
```
mkdir -p $HOME/.mucoin/cosmovisor/genesis/bin
cp $HOME/go/bin/mucoind $HOME/.mucoin/cosmovisor/genesis/bin/
```
```
ln -s $HOME/.mucoin/cosmovisor/genesis $HOME/.mucoin/cosmovisor/current -f
sudo ln -s $HOME/.mucoin/cosmovisor/current/bin/mucoind /usr/local/bin/mucoind -f
```
```
mucoind init Vinjan.Inc --chain-id mucoin-1
```
```
mucoind version --long | grep -e commit -e version -e server_name
```
```
PORT=157
sed -i -e "s%:26657%:${PORT}57%" $HOME/.mucoin/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.mucoin/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.mucoin/config/app.toml
```
```
wget -O $HOME/.mucoin/config/genesis.json https://raw.githubusercontent.com/dasgrid/mucoin/refs/heads/main/networks/mucoin-1/genesis.json
```
```
peers="14b942af909ff8740c52bea456949a5de4be98e8@peer-mucoin.vinjan-inc.com:15756,32361fe4a8e26a1096261c031a951ed31bb07598@169.58.22.139:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.mucoin/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0umuc\"/" $HOME/.mucoin/config/app.toml
```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.mucoin/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.mucoin/config/config.toml
```
```
sudo tee /etc/systemd/system/mucoind.service > /dev/null <<EOF
[Unit]
Description=mucoin
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_NAME=mucoind"
Environment="DAEMON_HOME=$HOME/.mucoin"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable mucoind
sudo systemctl restart mucoind
sudo journalctl -u mucoind -f -o cat
```
```
mucoind status 2>&1 | jq .sync_info
```
```
mucoind q bank balances $(mucoind keys show wallet -a)
```
```
mucoind comet show-validator
```
```
nano $HOME/.mucoin/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"lr1Ada6VtgyY9w3YMkJwXLPmMzsYJ8xEvvODTSdV2vw="},
  "amount": "900000000umuc",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://vinjan-inc.com",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.10",
  "commission-max-rate": "1",
  "commission-max-change-rate": "1",
  "min-self-delegation": "1"
}
```
```
mucoind tx staking create-validator $HOME/.mucoin/validator.json \
--from wallet \
--chain-id mucoin-1 \
--gas-prices=0.01umuc \
--gas-adjustment=1.5 \
--gas=auto
```
```
echo $(mucoind comet show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.mucoin/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
```
SNAP_RPC="https://rpc.mucoin.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.mucoin/config/config.toml
```


```
sudo systemctl stop mucoind
sudo systemctl disable mucoind
sudo rm /etc/systemd/system/mucoind.service
sudo systemctl daemon-reload
rm -f $(which mucoind)
rm -rf .mucoin
rm -rf mucoin
```
