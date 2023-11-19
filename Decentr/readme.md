### Package
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
### Binary
```
cd $HOME
rm -rf decentr
git clone https://github.com/Decentr-net/decentr.git
git checkout v1.6.2
cd decentr
make install
```
### Update
```
cd decentr
git fetch --all
git checkout v1.6.3
make install
```
```
sudo systemctl restart decentrd
sudo journalctl -fu decentrd -o cat
```
### Init
```
MONIKER=
```
```
decentrd init $MONIKER --chain-id mainnet-3
decentrd config chain-id mainnet-3
decentrd config keyring-backend file
```
### Custom Port
```
PORT=47
decentrd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.decentr/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.decentr/config/app.toml
```
### Genesis
```
wget -O $HOME/.decentr/config/genesis.json https://raw.githubusercontent.com/Decentr-net/mainnets/master/3.0/genesis.json
```
### Addrbook
```
wget -O $HOME/.decentr/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/main/Decentr/addrbook.json
```
### Seed & Peer
```
sed -E -i 's/seeds = \".*\"/seeds = \"7708addcfb9d4ff394b18fbc6c016b4aaa90a10a@ares.mainnet.decentr.xyz:26656,8a3485f940c3b2b9f0dd979a16ea28de154f14dd@calliope.mainnet.decentr.xyz:26656,87490fd832f3226ac5d090f6a438d402670881d0@euterpe.mainnet.decentr.xyz:26656,3261bff0b7c16dcf6b5b8e62dd54faafbfd75415@hera.mainnet.decentr.xyz:26656,5f3cfa2e3d5ed2c2ef699c8593a3d93c902406a9@hermes.mainnet.decentr.xyz:26656,a529801b5390f56d5c280eaff4ae95b7163e385f@melpomene.mainnet.decentr.xyz:26656,385129dbe71bceff982204afa11ed7fa0ee39430@poseidon.mainnet.decentr.xyz:26656,35a934228c32ad8329ac917613a25474cc79bc08@terpsichore.mainnet.decentr.xyz:26656,0fd62bcd1de6f2e3cfc15852cdde9f3f8a7987e4@thalia.mainnet.decentr.xyz:26656,bd99693d0dbc855b0367f781fb48bf1ca6a6a58b@zeus.mainnet.decentr.xyz:26656\"/' $HOME/.decentr/config/config.toml
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.001udec"|g' $HOME/.decentr/config/app.toml
```
### Prunning
```
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="19"
sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.decentr/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.decentr/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.decentr/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.decentr/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/decentrd.service > /dev/null << EOF
[Unit]
Description=decentrd mainnet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which decentrd) start
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
sudo systemctl enable decentrd
sudo systemctl restart decentrd
sudo journalctl -fu decentrd -o cat
```
### Sync
```
decentrd status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -fu decentrd -o cat
```
### Add Wallet
```
decentrd keys add wallet
```
### Recover Wallet
```
decentrd keys add wallet --recover
```
### Balance
```
decentrd q bank balances decentr18yze7cvnep7d2yj3cs4zfpvd4juphxrwwzezd4
```
### Validator
```
decentrd tx staking create-validator -y \
  --chain-id mainnet-3 \
  --moniker <YOUR_MONIKER> \
  --pubkey "$(decentrd tendermint show-validator)" \
  --amount <AMMOUNT>udec \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --gas-adjustment="1.4" \
  --fees 250udec
```
### Unjail  
```
decentrd tx slashing unjail --from <wallet> --chain-id mainnet-3 --gas-adjustment="1.4" --gas auto --fees 250udec -y
```
### Withdraw  
```
decentrd tx distribution withdraw-all-rewards --from wallet --chain-id mainnet-3 --gas-adjustment="1.4" --gas auto --fees 250udec -y
```
### Withdraw with commission
```
decentrd tx distribution withdraw-rewards decentrvaloper18yze7cvnep7d2yj3cs4zfpvd4juphxrw3djwsz --commission --from wallet --chain-id mainnet-3  --fees 250udec -y
```
### Staking
```
decentrd tx staking delegate $(decentrd keys show wallet --bech val -a) 1000000udec --from wallet --chain-id mainnet-3 --gas-adjustment="1.4" --gas auto --fees 250udec -y
```
### Vote
```
decentrd tx gov vote 29 yes --from wallet --chain-id mainnet-3 --gas-adjustment="1.4" --gas auto --fees 250udec -y
```

### Delete 
```
sudo systemctl stop decentrd && \
sudo systemctl disable decentrd && \
rm /etc/systemd/system/decentrd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .decentr && \
rm -rf $(which decentrd)
```



