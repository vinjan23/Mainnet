```
sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

```
ver="1.19.3"
cd $HOME
rm -rf go
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

```
cd $HOME
rm -rf 8ball
git clone https://github.com/sxlmnwb/8ball
cd 8ball
git checkout v0.34.24
go build -o 8ball ./cmd/eightballd
```

```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
mkdir -p $HOME/.8ball/cosmovisor/genesis/bin
mv 8ball $HOME/.8ball/cosmovisor/genesis/bin/
```

```
ln -s $HOME/.8ball/cosmovisor/genesis $HOME/.8ball/cosmovisor/current
sudo ln -s $HOME/.8ball/cosmovisor/current/bin/8ball /usr/bin/8ball
```

```
8ball init sandra --chain-id eightball-1
8ball config chain-id eightball-1
8ball config keyring-backend file
```


```
curl -L "https://8ball.info/8ball-genesis.json" > genesis.json
mv genesis.json ~/.8ball/config/
wget -O $HOME/.8ball/config/addrbook.json "https://raw.githubusercontent.com/vinjan23/Mainnet/main/8ball/addrbook.json"
```


```
SEEDS=
PEERS=fca96d0a1d7357afb226a49c4c7d9126118c37e9@one.8ball.info:26656,aa918e17c8066cd3b031f490f0019c1a95afe7e3@two.8ball.info:26656,98b49fea92b266ed8cfb0154028c79f81d16a825@three.8ball.info:26656
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.8ball/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025uebl\"/" $HOME/.8ball/config/app.toml
```

```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.8ball/config/app.toml
```

```
PORT=28
8ball config node tcp://localhost:${PORT}657
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.8ball/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.8ball/config/app.toml
```

```
sudo tee /etc/systemd/system/8ball.service > /dev/null << EOF
[Unit]
Description=8ball
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.8ball"
Environment="DAEMON_NAME=8ball"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
```

```
sudo systemctl daemon-reload
sudo systemctl enable 8ball
sudo systemctl restart 8ball
sudo journalctl -fu 8ball -o cat
```

```
systemctl stop 8ball 
8ball tendermint unsafe-reset-all --home $HOME/.8ball --keep-addr-book

STATE_SYNC_RPC="https://8ball-rpc.genznodes.dev:443"

LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

PEERS=fb1aa0a42ceadeafaecb6dfa07215006b21ea1c1@154.26.138.73:28656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.8ball/config/config.toml

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/.8ball/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  $HOME/.8ball/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/.8ball/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.8ball/config/config.toml

systemctl restart 8ball && journalctl -fu 8ball -o cat
```

```
8ball status 2>&1 | jq .SyncInfo
```

```
sudo journalctl -fu 8ball -o cat
```

```
8ball keys add wallet
```

```
8ball keys add wallet --recover
```

```
8ball keys list
```

```
8ball query bank balances 8ball1xhflczu877d38vhg9z4n9890gjv0xpksegfmv3
```

```
8ball tx staking create-validator \
--amount=888000000uebl \
--pubkey=$(8ball tendermint show-validator) \
--moniker="sandra" \
--identity="5FA798920DF85EDC" \
--details="Please Ur Delegate make me growth" \
--website="YOUR_WEBSITE_URL" \
--chain-id=eightball-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=afung \
--fees=5000uebl
```

```
8ball tx staking edit-validator \
--new-moniker=sandra \
--website="https://sandra.xyz" \
--from=afung \
--chain-id=eightball-1 \
--fees=5000uebl
```

```
8ball tx slashing unjail --broadcast-mode=block --from wallet --chain-id eightball-1 --fees=5000uebl
```

```
8ball tx staking delegate <val_address> 888000000uebl --from wallet --chain-id eightball-1 --fees 5000uebl
```

```
8ball tx bank send wallet 8ball1xhflczu877d38vhg9z4n9890gjv0xpksegfmv3 888000000uebl --from wallet --chain-id eightball-1 --fees 5000uebl
```

```
8ball tx distribution withdraw-all-rewards --from wallet --chain-id eightball-1 --fees 5000uebl
```

```
8ball tx distribution withdraw-rewards $(8ball keys show wallet --bech val -a) --commission --chain-id eightball-1 --fees 5000uebl
```

```
[[ $(8ball q staking validator $(8ball keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(8ball status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

```
sudo systemctl stop 8ball && \
sudo systemctl disable 8ball && \
rm /etc/systemd/system/8ball.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf 8ball && \
rm -rf .8ball && \
rm -rf $(which 8ball)
```










