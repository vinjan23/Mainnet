```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

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

```
cd $HOME
curl -LOf https://github.com/CoreumFoundation/coreum/releases/download/v1.0.0/cored-linux-amd64
chmod +x cored-linux-amd64
mv cored-linux-amd64 $HOME/go/bin/cored
```

```
MONIKER=  
```

```
cored init $MONIKER --chain-id coreum-mainnet-1
```

```
PORT=46
cored config node tcp://localhost:${PORT}657
```

```
curl -Ls https://raw.githubusercontent.com/CoreumFoundation/coreum/master/genesis/coreum-mainnet-1.json  > $HOME/.core/coreum-mainnet-1/config/genesis.json
```

```
PEERS=57d728e6cd0b614c4d705a96ec4753297798ee69@94.16.120.57:46656,8cedd961a72c183686e9b0b67b6e54fccd6471c3@35.194.10.107:26656,81e76bc013acbb2048e7acfb2ab04d80732a3699@34.122.166.246:26656,55cec213e8f3738d2642147d857afab93b1a4ef6@34.172.192.61:26656,62b207017a272a1452ebe7e67018a4f6be1146d8@34.172.201.60:26656,094189cad7921baf44c280ee8efed959869f3a22@34.66.215.21:26656,d65085259afd2065796bba7430d61fe85042e1c3@190.92.219.25:26656,eeb17ff4b1dad8d20fdafc339c277f7a624bb84a@35.238.253.76:26656,92b67a34dbda739a92cd04561ac8c33bfa858477@34.67.59.88:26656,2505072cc9586c0c4fafa092a2352123d8c12936@34.28.225.76:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.core/coreum-mainnet-1/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ucore\"/" $HOME/.core/coreum-mainnet-1/config/app.toml
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.core/coreum-mainnet-1/config/config.toml
```

```
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.core/coreum-mainnet-1/config/app.toml
  ```
  
  ```
  sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.core/coreum-mainnet-1/config/config.toml
  ```
  
 ```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.core/coreum-mainnet-1/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.core/coreum-mainnet-1/config/app.toml
```

```
sudo tee /etc/systemd/system/cored.service > /dev/null <<EOF
[Unit]
Description=Coreeum Mainnet
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cored) start --home $HOME/.core/
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

```
sudo systemctl daemon-reload && \
sudo systemctl enable cored && \
sudo systemctl restart cored && \
sudo journalctl -u cored -f -o cat
```

```
cored status 2>&1 | jq .SyncInfo
```

```
sudo journalctl -u cored -f -o cat
```

```
cored keys add <WALLET> --keyring-backend file
```

```
cored keys add <WALLET> --keyring-backend file --recover
```

```
cored q bank balances <Wallet_Address>
```

```
cored tx staking create-validator \
--amount=20000000000ucore \
--pubkey="$(cored tendermint show-validator)" \
--moniker=vinjan \
--website="https://nodes.vinjan.xyz" \
--identity="7C66E36EA2B71F68" \
--commission-rate="0.02" \
--commission-max-rate="0.2" \
--commission-max-change-rate="0.01" \
--min-self-delegation=20000000000 \
--chain-id=coreum-testnet-1 \
--from=wallet \
--gas auto \
-y
```

```
cored tx staking edit-validator \
--new-moniker=<Your_Moniker> \
--identity= \
--website="" \
--details=satsetsatseterror \
--chain-id=coreum-testnet-1 \
--from=wallet \
--gas auto \
-y
```

```
cored tx slashing unjail --from wallet --chain-id coreum-mainnet-1 --gas-adjustment 1.4  --gas auto -y
```

```
cored tx staking delegate <TO_VALOPER_ADDRESS> 1000000ucore --from wallet --chain-id coreum-mainnet-1 --gas-adjustment 1.4 --gas auto -y
```

```
cored tx distribution withdraw-all-rewards --from wallet --chain-id coreum-mainnet-1 --gas-adjustment 1.4 --gas auto -y
```

```
cored tx distribution withdraw-rewards $(cored keys show wallet --bech val -a) --commission --from wallet --chain-id coreum-mainnet-1 --gas-adjustment 1.4 --gas auto -y
```

```
sudo systemctl restart cored
```

```
[[ $(cored q staking validator $(cored keys show wallet --bech val -a) -oj | jq -r .consensus_pubkey.key) = $(cored status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

```
sudo systemctl stop cored
sudo systemctl disable cored
sudo rm /etc/systemd/system/cored.service
sudo systemctl daemon-reload
rm -f $(which cored)
rm -rf .core
rm -rf coreum
```

  
