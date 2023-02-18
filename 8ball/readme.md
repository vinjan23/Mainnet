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
curl -L "https://8ball.info/8ball.tar.gz" > 8ball.tar.gz && \
tar -C ./ -vxzf 8ball.tar.gz && \
rm -f 8ball.tar.gz  && \
sudo mv ./8ball /usr/local/bin/
```
```
8ball config chain-id eightball-1
8ball config keyring-backend file
```
```
8ball init $MONIKER --chain-id eightball-1
```

```
curl -L "https://8ball.info/8ball-genesis.json" > genesis.json
mv genesis.json ~/.8ball/config/
```

```
SEEDS=
PEERS=fca96d0a1d7357afb226a49c4c7d9126118c37e9@one.8ball.info:26656,aa918e17c8066cd3b031f490f0019c1a95afe7e3@two.8ball.info:26656,98b49fea92b266ed8cfb0154028c79f81d16a825@three.8ball.info:26656
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.8ball/config/config.toml
```

```
sudo tee /etc/systemd/system/8ball.service > /dev/null <<EOF
[Unit]
Description=8ball
After=network-online.target

[Service]
User=$USER
ExecStart=$(which 8ball) start --home $HOME/.8ball
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

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
8ball query bank balances 8ball1jf02c7l9ezy30eflx0kgp54d0tpsj2zzhef7zv
```

```
8ball tx staking create-validator \
--moniker=vinjan \
--amount=50000000uebl \
--pubkey=$(8ball tendermint show-validator) \
--chain-id=eightball-1 \
--commission-rate="0.1" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="100" \
--from=wallet
--identity=7C66E36EA2B71F68 \
--details=node.vinjan.xyz \
--gas=auto \
-Y
```

```
8ball tx staking edit-validator \
 --new-moniker=vinjan \
 --identity=7C66E36EA2B71F68 \
 --website=nodes.vinjan.xyz \
 --details=satsetsatseterror \
 --chain-id=eightball-1 \
 --from=wallet \
 --gas=auto \
 -y
 ```
 
```
8ball tx staking delegate 8ballvaloper1jf02c7l9ezy30eflx0kgp54d0tpsj2zz3zmn8h 888000000uebl --from wallet --chain-id eightball-1 --gas auto -y
``` 
  
  
  
  








