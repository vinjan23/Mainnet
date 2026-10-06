```
cd $HOME
rm -rf epix
git clone https://github.com/EpixZone/EpixChain.git
cd epix
git checkout v0.5.2
make install
```
```
mkdir -p $HOME/.epixd/cosmovisor/genesis/bin
cp $HOME/go/bin/epixd $HOME/.epixd/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.epixd/cosmovisor/genesis $HOME/.epixd/cosmovisor/current -f
sudo ln -s $HOME/.epixd/cosmovisor/current/bin/epixd /usr/local/bin/epixd -f
```
```
wget https://github.com/EpixZone/EpixChain/releases/download/v0.5.2-fix/epixd
mkdir -p $HOME/.epixd/cosmovisor/upgrades/v0.5.2/bin
cp epixd $HOME/.epixd/cosmovisor/upgrades/v0.5.2/bin/
```
```
chmod +x $HOME/.epixd/cosmovisor/upgrades/v0.5.2/bin/epixd
```
### Upgrade
```
cd $HOME
rm -rf EpixChain
git clone https://github.com/EpixZone/EpixChain.git
cd EpixChain
git checkout v0.7.3
make install
```
```
mkdir -p $HOME/.epixd/cosmovisor/upgrades/v0.7.2/bin
cp $HOME/go/bin/epixd $HOME/.epixd/cosmovisor/upgrades/v0.7.2/bin/
```
```
$HOME/.epixd/cosmovisor/upgrades/v0.7.2/bin/epixd version --long | grep -e commit -e version -e server_name
```
```
epixd version --long | grep -e commit -e version
```

```
epixd init Vinjan.Inc --chain-id epix_1916-1
epixd config set client chain-id epix_1916-1
```
```
PORT=399
sed -i -e "s%:26657%:${PORT}57%" $HOME/.epixd/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.epixd/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%; s%:8545%:${PORT}45%; s%:8546%:${PORT}46%; s%:6065%:${PORT}65%" $HOME/.epixd/config/app.toml
```
```
wget -O genesis.json https://services.silknodes.io/genesis/epix/genesis.json --inet4-only
mv genesis.json ~/.epixd/config
```
```
wget -O addrbook.json https://services.silknodes.io/addrbook/epix/addrbook.json --inet4-only
mv addrbook.json ~/.epixd/config
```
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"20000000000aepix\"/" $HOME/.epixd/config/app.toml

```
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "30"|' \
$HOME/.epixd/config/app.toml
```
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.epixd/config/config.toml
```
```
sudo tee /etc/systemd/system/epixd.service > /dev/null <<'EOF'
[Unit]
Description=epix
After=network-online.target

[Service]
User=vinjan
WorkingDirectory=/home/vinjan
ExecStart=/home/vinjan/go/bin/cosmovisor run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=/home/vinjan/.epixd"
Environment="DAEMON_NAME=epixd"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
```
```
sed -i 's/^type = "flood"/type = "app"/' $HOME/.bitbadgeschain/config/config.toml
```
```
cat <<EOF >> ~/.epixd/config/app.toml
[topholders]

enable = true
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable epixd
sudo systemctl restart epixd
sudo journalctl -u epixd -f -o cat
```
```
epixd status 2>&1 | jq .sync_info
```
```
epixd q bank balances $(epixd keys show wallet -a --keyring-backend file)
```
```
epixd comet show-validator
```
```
nano $HOME/.epixd/validator.json
```
```
{
  "pubkey": ,
  "amount": "999000000000000000000apix",
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
epixd tx staking create-validator $HOME/.epixd/validator.json \
--from wallet \
--chain-id epix_1916-1 \
--gas-prices="0.001aepix" \
--gas-adjustment=1.2 \
--gas=auto
```
```
 epixd tx staking edit-validator \
--new-moniker="Vinjan.Inc | RESTAKE" \
--identity="7C66E36EA2B71F68" \
--website="https://vinjan-inc.com" \
--details="Staking Provider-IBC Relayer" \
--chain-id epix_1916-1 \
--commission-rate=0.04 \
--from=wallet \
--gas-prices="20000000000aepix" \
--gas-adjustment=1.5 \
--gas=auto
```
```
epixd tx distribution withdraw-rewards $(epixd keys show wallet --bech val -a) --commission --from wallet --chain-id epix_1916-1 --gas-adjustment=1.5 --gas-prices="20000000000aepix" --gas=auto --keyring-backend file -y
```

```
epixd tx staking delegate $(epixd keys show wallet --bech val -a) 1000000000000000000aepix --from wallet --chain-id epix_1916-1 --gas-adjustment=1.2 --gas-prices=20000000000aepix --gas=auto --keyring-backend file -y
```
```
epixd tx gov vote 7 yes --from wallet --chain-id epix_1916-1 --gas-adjustment=1.5 --gas-prices=20000000000aepix --gas=auto --keyring-backend file -y
```
```
epixd comet unsafe-reset-all --home home/vinjan/.epixd --keep-addr-book
curl https://services.silknodes.io/snapshots/epix/epix_5820326.tar.zst | zstd -dc - | tar -xf - -C /home/vinjan/.epixd
```
```
peers="a32a7e52701de6efecfc4388b4c9f3c086c37387@65.108.229.19:26986"
sed -i -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.epixd/config/config.toml
```
```
sudo systemctl stop epixd
cp $HOME/.epixd/data/priv_validator_state.json $HOME/.epixd/priv_validator_state.json.backup
epixd comet unsafe-reset-all --home $HOME/.epixd --keep-addr-book
```
```
SNAP_RPC="https://epix.rpc.m.anode.team:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
sed -i \
-e "s|^enable *=.*|enable = true|" \
-e "s|^rpc_servers *=.*|rpc_servers = \"$SNAP_RPC,$SNAP_RPC\"|" \
-e "s|^trust_height *=.*|trust_height = $BLOCK_HEIGHT|" \
-e "s|^trust_hash *=.*|trust_hash = \"$TRUST_HASH\"|" \
$HOME/.epixd/config/config.toml
mv $HOME/.epixd/priv_validator_state.json.backup $HOME/.epixd/data/priv_validator_state.json
```
```
sudo systemctl restart epixd
sudo journalctl -u epixd -f -o cat

```

```
sudo systemctl stop epixd
rm -rf $HOME/.epixd/data
epixd comet unsafe-reset-all --home $HOME/.epixd --keep-addr-book
```
```
sudo systemctl stop epixd
sudo systemctl disable epixd
sudo rm /etc/systemd/system/epixd.service
sudo systemctl daemon-reload
rm -rf $(which epixd)
rm -rf .epixd
rm -rf EpixChain
```
9c608d8d9f60ca4912f758904cab6ee58f166eda@2a01:4f9:6a:2126::2:39956

