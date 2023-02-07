## Update Tool
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## GO
```
ver="1.19.1"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Build Binary
```
git clone https://github.com/ArableProtocol/acrechain.git
cd acrechain
git checkout v1.1.1
make install
```

## Setup NodeName
```
MONIKER=Your_NODENAME
```

## Init
```
acred init $MONIKER --chain-id acre_9052-1
acred config chain-id acre_9052-1
acred config keyring-backend test
acred config node tcp://localhost:13657
```

## Download Genesis
```
wget https://raw.githubusercontent.com/ArableProtocol/acrechain/main/networks/mainnet/acre_9052-1/genesis.json -O $HOME/.acred/config/genesis.json
```

## Download Addrbook
```

```

## Set Peers & Seed
```
PEERS="ef28f065e24d60df275b06ae9f7fed8ba0823448@46.4.81.204:34656,e29de0ba5c6eb3cc813211887af4e92a71c54204@65.108.1.225:46656,276be584b4a8a3fd9c3ee1e09b7a447a60b201a4@116.203.29.162:26656,e2d029c95a3476a23bad36f98b316b6d04b26001@49.12.33.189:36656,1264ee73a2f40a16c2cbd80c1a824aad7cb082e4@149.102.146.252:26656,dbe9c383a709881f6431242de2d805d6f0f60c9e@65.109.52.156:7656,d01fb8d008cb5f194bc27c054e0246c4357256b3@31.7.196.72:26656,91c0b06f0539348a412e637ebb8208a1acdb71a9@178.162.165.193:21095,bac90a590452337700e0033315e96430d19a3ffa@23.106.238.167:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.acred/config/config.toml
```

## Prunning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.acred/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.acred/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.acred/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.acred/config/app.toml
```

## Custom Port
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:13658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:13657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:13060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:13656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":13660\"%" $HOME/.acred/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:13317\"%; s%^address = \":8080\"%address = \":13080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:13090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:13091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:13545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:13546\"%" $HOME/.acred/config/app.toml
```

## disable Indexing
```
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.acred/config/config.toml
```

## Create Servive
```
sudo tee /etc/systemd/system/acred.service > /dev/null << EOF
[Unit]
Description=Acre Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which acred) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Start
```
sudo systemctl daemon-reload
sudo systemctl enable acred
sudo systemctl restart acred
sudo journalctl -u acred -f -o cat
```

## Snapshot
```
sudo apt update 
sudo apt install snapd -y 
sudo snap install lz4 
sudo systemctl stop acred
acred tendermint unsafe-reset-all --home $HOME/.acred --keep-addr-book
curl -L https://snapshots.nodestake.top/acre/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.acred
sudo systemctl restart acred
journalctl -fu acred -o cat
```

## Sync Info
```
acred status 2>&1 | jq .SyncInfo
```

## Create Wallet
```
acred keys add <wallet-name>
```

## Check Balance
```
acred query bank balances <wallet-address> --chain-id acre_9052-1
```

## Create Validator
```
acred tx staking create-validator \
  --moniker=<moniker-name> \
  --chain-id=acre_9052-1 \
  --pubkey="$(acred tendermint show-validator)" \
  --amount=5000000000000000000aacre \
  --identity="<Keybase.io ID>" \
  --website="<website-address>" \
  --details="Some description" \
  --from=<wallet-name> \
  --commission-rate=0.1 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation=1
  --gas=auto \
  -y 
  ```
  
## Edit Validator
```
acred tx staking edit-validator \
--new-moniker=<moniker-name> \
--chain-id=acre_9052-1 \
--identity="<Keybase.io ID>" \
--website="<website-address>" \
--details="Some description" \
--gas=auto \
-y 
```

## Delegate
```
acred tx staking delegate <validator-address> 1000000000000000000aacre --from <wallet-name> --chain-id acre_9052-1 --gas auto -y
```

## Withdraw Reward
```
acred tx distribution withdraw-rewards <validator-address> --from <wallet-name> --chain-id acre_9052-1 --gas auto -y
```







  








