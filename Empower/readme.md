### Update
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### GO
```
ver="1.20.4"
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
git clone https://github.com/EmpowerPlastic/empowerchain.git
cd empowerchain
git checkout v1.0.0
cd chain
make install
```

### Init
```
MONIKER=
```
```
empowerd init $MONIKER --chain-id empowerchain-1
empowerd config chain-id empowerchain-1
empowerd config keyring-backend file
```

### Custom Port
```
PORT=
empowerd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.empowerchain/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.empowerchain/config/app.toml
```

### Genesis
```
URL=https://github.com/EmpowerPlastic/empowerchain/raw/main/mainnet/empowerchain-1/genesis.tar.gz
curl -L $URL | tar -xz -C $HOME/.empowerchain/config/
```

### Addrbook
```
wget -O $HOME/.empowerchain/config/addrbook.json "https://services.empowerchain-1.empower.aviaone.com/addrbook.json"
```

### Seed Peer Gas
```
seeds="a1427b456513ab70967a2a5c618d347bc89e8848@seed.empowerchain.io:26656,6740fa259552a628266a85de8c2a3dee7702b8f9@empower-mainnet-seed.itrocket.net:14656,e16668ddd526f4e114ebb6c4714f0c18c0add8f8@empower-seed.zenscape.one:26656,f2ed98cf518b501b6d1c10c4a16d0dfbc4a9cc98@tenderseed.ccvalidators.com:27001,258f523c96efde50d5fe0a9faeea8a3e83be22ca@seed.empowerchain-1.empower.aviaone.com:10274"
sed -i -e 's|^seeds *=.*|seeds = "'$seeds'"|' $HOME/.empowerchain/config/config.toml
peers="192d6c396fe0f9da1b1b700aab8bdd1ce6a49490@empw-m.peers.stavr.tech:22056,9c2aaafb8b9be8cb74705aaf95f4d51506244e3f@65.109.96.189:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.empowerchain/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0umpwr\"|" $HOME/.empowerchain/config/app.toml
```

### Prunning
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.empowerchain/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.empowerchain/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.empowerchain/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.empowerchain/config/app.toml
```

### Indexer Off
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.empowerchain/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/empowerd.service << EOF
[Unit]
Description=empower
After=network-online.target

[Service]
User=$USER
ExecStart=$(which empowerd) start
RestartSec=3
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start
```
sudo systemctl daemon-reload
sudo systemctl enable empowerd
sudo systemctl restart empowerd
sudo journalctl -u empowerd -f -o cat
```

### Sync
```
empowerd status 2>&1 | jq .SyncInfo
```
### Log
```
sudo journalctl -u empowerd -f -o cat
```

### Wallet
```
empowerd keys add wallet
```
### Recover
```
empowerd keys add wallet --recover
```

### Balances
```
empowerd q bank balances $(empowerd keys show wallet -a)
```

### Validator
```
empowerd tx staking create-validator \
--amount 1000000umpwr \
--chain-id empowerchain-1 \
--commission-max-change-rate 0.1 \
--commission-max-rate 0.2 \
--commission-rate 0.05 \
--min-self-delegation "1" \
--moniker "vinjan" \
--details="🎉Proffesional Stake & Node Validator🎉" \
--website "https://service.vinjan.xyz" \
--security-contact="<validator-security-contact>" \
--identity="7C66E36EA2B71F68" \
--from wallet \
--pubkey=$(empowerd tendermint show-validator) \
--gas-adjustment=1.5 \
--gas=auto 
```

### Edit
```
empowerd tx staking edit-validator \
--new-moniker ""  \
--chain-id empowerchain-1 \
--details "" \
--identity "" \
--from "" \
--gas-prices 0.025umpwr
```
### Unjail
```
empowerd tx slashing unjail --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```
### Jail reason
```
empowerd query slashing signing-info $(empowerd tendermint show-validator)
```

### Delegate
```
empowerd tx staking delegate $(empowerd keys show wallet --bech val -a) 900000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```
### Delegate to Another Validator
```
empowerd tx staking redelegate $(empowerd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 1000000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```

### Withdraw
```
empowerd tx distribution withdraw-all-rewards --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```
### Withdraw with Commission
```
empowerd tx distribution withdraw-rewards $(empowerd keys show wallet --bech val -a) --commission --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```

### Transfer
```
empowerd tx bank send wallet <TO_WALLET_ADDRESS> 1000000umpwr --from wallet --chain-id empowerchain-1
```

### Vote 
```
empowerd tx gov vote 1 yes --from wallet --chain-id empowerchain-1 --gas-adjustment 1.5 --gas auto
```

### Check Matches
```
[[ $(empowerd q staking validator $(empowerd keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(empowerd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```
### Own Peer
```
echo $(empowerd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.empowerd/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

### Stop
```
sudo systemctl stop empowerd
```
### Restart
```
sudo systemctl restart empowerd
```
### Node Info
```
empowerd status 2>&1 | jq .NodeInfo
```
### Validator Info
```
empowerd status 2>&1 | jq .ValidatorInfo
```

### Delete
```
sudo systemctl stop empowerd
sudo systemctl disable empowerd
sudo rm /etc/systemd/system/empowerd.service
sudo systemctl daemon-reload
rm -f $(which empowerd)
rm -rf $HOME/.empowerchain
rm -rf $HOME/empowerchain
```


