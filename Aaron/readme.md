### Go
```
ver="1.23.3"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
```
sudo curl https://get.ignite.com/cli | sudo bash
sudo mv ignite /usr/local/bin/
```
### Binary
```
cd $HOME
git clone https://github.com/aaronetwork/aaronetwork-chain.git
cd aaronetwork-chain
git checkout v1.0.0
ignite chain build
```
### Init
```
aaronetworkd init Vinjan.Inc --chain-id aaronetwork
```
### Genesis
```
wget -O $HOME/.aaronetwork/config/genesis.json https://raw.githubusercontent.com/aaronetwork/chain-genesis/refs/heads/main/genesis.json
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:14657\"%" $HOME/.aaronetwork/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:14658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:14657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":14660\"%" $HOME/.aaronetwork/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:14317\"%; s%^address = \"localhost:9090\"%address = \"localhost:14090\"%" $HOME/.aaronetwork/config/app.toml
```
### Peer Gas
```
peers="dc647a7389d3396b0a0d72d71240b02c30c47ef7@63.250.41.78:26656,1a8c6f839120a18ff270bf3a0e57e14db6d2301c@212.34.129.79:26656,7105c9f21b0a22ba243f22d9a27ea940d2638e79@77.238.248.110:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.aaronetwork/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uaaron\"/" $HOME/.aaronetwork/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.aaronetwork/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.aaronetwork/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/aaronetworkd.service > /dev/null <<EOF
[Unit]
Description=aaronetwork
After=network-online.target

[Service]
User=$USER
ExecStart=$(which aaronetworkd) start
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
sudo systemctl enable aaronetworkd
sudo systemctl restart aaronetworkd
sudo journalctl -u aaronetworkd -f -o cat
```
### Sync
```
aaronetworkd status 2>&1 | jq .sync_info
```

### Balances
```
aaronetworkd q bank balances $(aaronetworkd keys show wallet -a)
```

### Validator
```
aaronetworkd tendermint show-validator
```
```
nano /root/.aaronetwork/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"hZS3O9BCLLwu6Qtg9cT89ipCGTqc/jLHcHNadKWFIVY="},
  "amount": "1000000uaaron",
  "moniker": "Vinjan.Inc",
  "identity": "7C66E36EA2B71F68",
  "website": "https://service.vinjan.xyz",
  "security": "",
  "details": "Staking Provider-IBC Relayer",
  "commission-rate": "0.05",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.05",
  "min-self-delegation": "1"
}
```
```
aaronetworkd tx staking create-validator $HOME/.aaronetwork/validator.json \
--from wallet \
--chain-id aaronetwork
```
### Snapshot ( Height 271934 )
```
curl -L https://snapshot.vinjan.xyz./aaron/latest.tar.lz4  | lz4 -dc - | tar -xf - -C $HOME/.aaronetwork
```


