### GO
```
ver="1.22.6"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
### Binary
```
cd $HOME
rm -rf elys
git clone https://github.com/elys-network/elys
cd elys
git checkout v2.2.0
make build
```
### Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0
```
```
mkdir -p $HOME/.elys/cosmovisor/genesis/bin
mv build/elysd $HOME/.elys/cosmovisor/genesis/bin/
rm -rf build
```
```
ln -s $HOME/.elys/cosmovisor/genesis $HOME/.elys/cosmovisor/current -f
sudo ln -s $HOME/.elys/cosmovisor/current/bin/elysd /usr/local/bin/elysd -f
```
### Update
```
cd $HOME
rm -rf elys
git clone https://github.com/elys-network/elys
cd elys
git checkout v6.5.0
make install
```
```
mkdir -p $HOME/.elys/cosmovisor/upgrades/v6.5/bin
cp -a $HOME/go/bin/elysd $HOME/.elys/cosmovisor/upgrades/v6.5/bin/
```

```
cd $HOME
rm -rf elys
git clone https://github.com/elys-network/elys
cd elys
git checkout v6.5.0
make build
```
```
mkdir -p $HOME/.elys/cosmovisor/upgrades/v6.5/bin
mv build/elysd $HOME/.elys/cosmovisor/upgrades/v6.5/bin/
rm -rf build
```
```
$HOME/.elys/cosmovisor/upgrades/v6.5/bin/elysd version --long | grep -e commit -e version
```
```
elysd version --long | grep -e commit -e version
```
```
sudo systemctl stop elysd
rm -rf elys
git clone https://github.com/elys-network/elys.git
cd elys
git fetch --tag
git checkout v6.4.1
make install
```
```
cp -a $HOME/go/bin/elysd $HOME/.elys/cosmovisor/upgrades/v6.4/bin/
```
```
ls -l $HOME/.elys/cosmovisor/current
rm $HOME/.elys/cosmovisor/current
ln -s $HOME/.elys/cosmovisor/upgrades/v6.4 $HOME/.elys/cosmovisor/current
```
### Init
```
elysd init Vinjan.Inc --chain-id elys-1
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:16657\"%" $HOME/.elys/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":16660\"%" $HOME/.elys/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:16317\"%; s%^address = \"localhost:9090\"%address = \"localhost:16090\"%" $HOME/.elys/config/app.toml
```

### Genesis
```
wget -O $HOME/.elys/config/genesis.json https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/mainnet/genesis.json
```
```
curl -Ls https://github.com/elys-network/networks/blob/main/mainnet/genesis.json > $HOME/.elys/config/genesis.json  

```
### Addrbook
```
wget -O $HOME/.elys/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Elys/addrbook.json
```
### Peer
```
peers="949ee3582bab917fc4dd89829871bd46c8b366d8@162.55.245.228:46656,d95bdf717eb751667586b5e31083770630742038@65.109.58.158:22156,380048bb45143b2b87c540c772886f5a08bae344@86.90.185.145:26156,1d079e8b757b21b390f3eca0880ca03f7f90d8f0@95.217.143.167:20656,a0d2b6ed5911c830666cb5ff6df17a0438758e69@38.242.153.88:26656,d71d3bce45274bf8354298042674a08c778f6d27@202.61.243.56:22056"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.elys/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00025uelys\"|" $HOME/.elys/config/app.toml
```
### Gas Prices
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.01uelys,0.001ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349,0.0002ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9,11395000000ibc/8464A63954C0350A26C8588E20719F3A0AC8705E4CA0F7450B60C3F16B2D3421\"|" $HOME/.elys/config/app.toml
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = ""|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.elys/config/app.toml
```
### Service
```
sudo tee /etc/systemd/system/elysd.service > /dev/null << EOF
[Unit]
Description=elys
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
Environment="DAEMON_NAME=elysd"
Environment="DAEMON_HOME=$HOME/.elys"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable elysd
```
```
sudo systemctl restart elysd
```
```
sudo journalctl -u elysd -f -o cat
```
### Sync
```
elysd status 2>&1 | jq .sync_info
```
### Wallet
```
elysd keys add wallet --recover
```
### Balances
```
elysd q bank balances $(elysd keys show wallet -a)
```
### Create Gov
```
elysd tendermint show-validator
```
```
nano /root/.elys/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":""},
  "amount": "25000000uelys",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider",
  "commission-rate": "0.1",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.05",
  "min-self-delegation": "1"
}
```
```
elysd tx staking create-validator $HOME/.elys/validator.json \
--from wallet \
--chain-id elys-1 \
--gas auto \
--gas-adjustment 1.2 \
--fees 250uelys
```
### Edit
```
elysd tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--commission-rate="0.05" \
--chain-id elys-1 \
--from wallet \
--gas auto \
--gas-adjustment 1.2 \
--fees 250uelys
```
### Vote
```
elysd tx gov vote 31 yes --from wallet --chain-id elys-1 --gas auto --gas-adjustment 1.2 --fees 250uelys
```
### WD
```
elysd tx distribution withdraw-rewards $(elysd keys show wallet --bech val -a) --commission --from wallet --chain-id elys-1 --gas auto --gas-adjustment 1.2 --fees 250uelys
```
```
sudo systemctl stop elysd
cp $HOME/.elys/data/priv_validator_state.json $HOME/.elys/priv_validator_state.json.backup
elysd tendermint unsafe-reset-all --home $HOME/.elys --keep-addr-book
SNAP_RPC="https://elys-rpc.polkachu.com:443"
SYNC_PEER="2b8417ec0e27025a10b494a71b92349e5e38487c@65.109.115.172:22056"
LATEST_HEIGHT=$(curl -s $SYNC_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$SYNC_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i \
-e "s|^enable *=.*|enable = true|" \
-e "s|^rpc_servers *=.*|rpc_servers = \"$SYNC_RPC,$SYNC_RPC\"|" \
-e "s|^trust_height *=.*|trust_height = $BLOCK_HEIGHT|" \
-e "s|^trust_hash *=.*|trust_hash = \"$TRUST_HASH\"|" \
-e "s|^persistent_peers *=.*|persistent_peers = \"$SYNC_PEER\"|" \
$HOME/.elys/config/config.toml
mv $HOME/.elys/priv_validator_state.json.backup $HOME/.elys/data/priv_validator_state.json
sudo systemctl restart elysd && sudo journalctl -u elysd -f -o cat
```
### Delete
```
sudo systemctl stop elysd
sudo systemctl disable elysd
sudo rm /etc/systemd/system/elysd.service
sudo systemctl daemon-reload
rm -rf $(which elysd)
rm -rf $HOME/.elys
rm -rf $HOME/elys
```



