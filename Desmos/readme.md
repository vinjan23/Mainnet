### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### GO
```
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### Build
```
cd $HOME
git clone https://github.com/desmos-labs/desmos.git
cd desmos
git checkout v4.7.0
make install
```
### Setup Moniker
```
MONIKER=
```
### Init
```
PORT=43
desmos init $MONIKER --chain-id desmos-mainnet
desmos config chain-id desmos-mainnet
desmos config keyring-backend file
desmos config node tcp://localhost:${PORT}657
```
### Genesis & Addrbook
```
curl -s https://raw.githubusercontent.com/desmos-labs/mainnet/main/genesis.json > $HOME/.desmos/config/genesis.json
wget -O $HOME/.desmos/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/Desmos/addrbook.json"
```
### Gas & Seed & Peer
```
SEEDS="9bde6ab4e0e00f721cc3f5b4b35f3a0e8979fab5@seed-1.mainnet.desmos.network:26656,5c86915026093f9a2f81e5910107cf14676b48fc@seed-2.mainnet.desmos.network:26656,45105c7241068904bdf5a32c86ee45979794637f@seed-3.mainnet.desmos.network:26656"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.desmos/config/config.toml
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001udsm"|g' $HOME/.desmos/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.desmos/config/config.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "kv"|' $HOME/.desmos/config/config.toml
```
### Prunning
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.desmos/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.desmos/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.desmos/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.desmos/config/app.toml
```

### Custom Port
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.desmos/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.desmos/config/app.toml
```
### Create Service
```
sudo tee /etc/systemd/system/desmos.service > /dev/null <<EOF
[Unit]
Description=desmos mainnet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which desmos) start
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
sudo systemctl enable desmos
sudo systemctl restart desmos
sudo journalctl -fu desmos -o cat
```
### Statesync
```
sudo systemctl stop desmos
cp $HOME/.desmos/data/priv_validator_state.json $HOME/.desmos/priv_validator_state.json.backup
desmos tendermint unsafe-reset-all --home $HOME/.desmos --keep-addr-book
SNAP_RPC="https://desmos.nodejumper.io:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
PEERS="f090ead239426219d605b392314bdd73d16a795f@desmos.nodejumper.io:32656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.desmos/config/config.toml
sed -i 's|^enable *=.*|enable = true|' $HOME/.desmos/config/config.toml
sed -i 's|^rpc_servers *=.*|rpc_servers = "'$SNAP_RPC,$SNAP_RPC'"|' $HOME/.desmos/config/config.toml
sed -i 's|^trust_height *=.*|trust_height = '$BLOCK_HEIGHT'|' $HOME/.desmos/config/config.toml
sed -i 's|^trust_hash *=.*|trust_hash = "'$TRUST_HASH'"|' $HOME/.desmos/config/config.toml
mv $HOME/.desmos/priv_validator_state.json.backup $HOME/.desmos/data/priv_validator_state.json
sudo systemctl restart desmos && journalctl -u desmos -f -o cat
```

### Sync Info
```
desmos status 2>&1 | jq .SyncInfo
```
### Create Wallet
```
desmos keys add <WALLET>
```
### Recover Wallet
```
desmos keys add wallet --recover
```
### List all wallet
```
desmos keys list
```
### Check Balances
```
desmos q bank balances desmos1a59zedna28qj6p0yx3x9fxu920ffx3m7dfr8ju
```
### Create Validator
```
desmos tx staking create-validator \
--amount=557000000udsm \
--pubkey=$(desmos tendermint show-validator) \
--moniker="vinjan" \
--identity=7C66E36EA2B71F68 \
--website=https://nodes.vinjan.xyz \
--details="https://explorer.vinjan.xyz" \
--chain-id=desmos-mainnet \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-prices=0.1udsm \
--gas-adjustment=1.5 \
--gas=auto \
-y
```
### Editing
```
desmos tx staking edit-validator \
--new-moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL"
--chain-id=desmos-mainnet \
--from=<WALLET> \
--fees 200udsm \
-y
```
### Unjail
```
desmos tx slashing unjail --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
### Delegate
```
desmos tx staking delegate <validator> 1000000udsm --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
### Withdraw All
```
desmos tx distribution withdraw-all-rewards --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
### Withdraw with commission
```
desmos tx distribution withdraw-rewards <VALOPER> --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```
### Unbond/Unstake
```
desmos tx staking unbond $(desmos keys show <WALLET> --bech val -a) 1000000udsm --from <WALLET> --chain-id desmos-mainnet --fees 200udsm -y
```

### Transfer
```
desmos tx bank send <WALLET> <TO_WALLET_ADDRESS> 1000000udsm --from <WALLET> --fees 200udsm --chain-id desmos-mainnet
```
### Validator Info
```
desmos status 2>&1 | jq .ValidatorInfo
```

### Check Validator match with wallet
```
[[ $(desmos q staking validator $(desmos keys show <WALLET> --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(desmos status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Stop 
```
sudo systemctl stop desmos
```
### Restart
```
sudo systemctl restart desmos
```

### Delete Node
```
cd $HOME
sudo systemctl stop desmos
sudo systemctl disable desmos
sudo rm /etc/systemd/system/desmos.service
sudo systemctl daemon-reload
rm -rf $(which desmos) 
rm -rf $HOME/.desmos
rm -rf $HOME/rebus.core
```










