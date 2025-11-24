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
cd decentr
git checkout v1.6.4
make install
```
```
mkdir -p $HOME/.decentr/cosmovisor/genesis/bin
cp $HOME/go/bin/decentrd $HOME/.decentr/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.decentr/cosmovisor/genesis $HOME/.decentr/cosmovisor/current -f
sudo ln -s $HOME/.decentr/cosmovisor/current/bin/decentrd /usr/local/bin/decentrd -f
```

### Init

```
decentrd init Vinjan.Inc --chain-id mainnet-3
```
### Custom Port
```
PORT=47
sed -i -e "s%:26657%:${PORT}657%" $HOME/.decentr/config/client.toml
sed -i -e "s%:26658%:${PORT}658%; s%:26657%:${PORT}657%; s%:6060%:${PORT}060%; s%:26656%:${PORT}656%; s%:26660%:${PORT}661%" $HOME/.decentr/config/config.toml
sed -i -e "s%:1317%:${PORT}317%; s%:8080%:${PORT}080%; s%:9090%:${PORT}090%; s%:9091%:${PORT}091%" $HOME/.decentr/config/app.toml
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
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.001udec"|g' $HOME/.decentr/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.decentr/config/app.toml
```
### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.decentr/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/decentrd.service > /dev/null << EOF
[Unit]
Description=decentr
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.decentr"
Environment="DAEMON_NAME=decentrd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.decentr/cosmovisor/current/bin"

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
```
decentrd tx staking edit-validator \
--new-moniker "Vinjan.Inc" \
--identity "7C66E36EA2B71F68" \
--website "https://service.vinjan.xyz" \
--details "Staking Provider & IBC Relayer" \
--chain-id mainnet-3 \
--from wallet \
--gas auto \
--gas-adjustment="1.4" \
--fees 250udec
```  
### Unjail  
```
decentrd tx slashing unjail --from wallet --chain-id mainnet-3 --gas-adjustment="1.4" --gas auto --fees 250udec -y
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



