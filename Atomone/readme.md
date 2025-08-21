### Go
```
ver="1.22.10"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.22.12.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```
### Binary
```
cd $HOME
rm -rf atomone
git clone https://github.com/atomone-hub/atomone
cd atomone
git checkout v1.1.2
make install
```
```
mkdir -p $HOME/.atomone/cosmovisor/genesis/bin
cp $HOME/go/bin/atomoned $HOME/.atomone/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.atomone/cosmovisor/genesis $HOME/.atomone/cosmovisor/current -f
sudo ln -s $HOME/.atomone/cosmovisor/current/bin/atomoned /usr/local/bin/atomoned -f
```
### Update
```
cd $HOME
rm -rf atomone
git clone https://github.com/atomone-hub/atomone.git
cd atomone
git checkout v2.1.0
make install
```
```
mkdir -p $HOME/.atomone/cosmovisor/upgrades/v2/bin
mv build/atomoned $HOME/.atomone/cosmovisor/upgrades/v2/bin/
rm -rf build
```
```
mkdir -p $HOME/.atomone/cosmovisor/upgrades/v2.1.0/bin
cp $HOME/go/bin/atomoned $HOME/.atomone/cosmovisor/upgrades/v2.1.0/bin/
```
```
sudo systemctl stop atomoned
cp $HOME/go/bin/atomoned $HOME/.atomone/cosmovisor/upgrades/v2/bin/
```

```
$HOME/.atomone/cosmovisor/upgrades/v2.1.0/bin/atomoned version --long | grep -e commit -e version
```
```
atomoned version --long | grep -e commit -e version
```
### Init
```
atomoned init Vinjan.Inc --chain-id atomone-1
atomoned config chain-id atomone-1
atomoned config keyring-backend file
```
### Port
```
PORT=15
atomoned config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.atomone/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%" $HOME/.atomone/config/app.toml
```
### Genesis
```
wget -O $HOME/.atomone/config/genesis.json  https://atomone.fra1.digitaloceanspaces.com/genesis.json
```
### Addrbook
```
wget -O $HOME/.atomone/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Atomone/addrbook.json
```

### Seed Peers
```
seeds=""
sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.atomone/config/config.toml
peers="522826623d65d27ef3f7db8a5259d003be5a93d3@65.108.229.19:26666,da165aaeac3adbc9845879e06f336c2668c5d915@65.21.214.84:9756,ca1d8ab2fdc1cbff4c8283ddbcc8fd53a7d9a254@65.21.215.167:26656,a31d85900f6562b3a8b275617359643a5607ed40@146.70.243.163:26656,2c02f0e92e00a7fdacdfafb1919b3424047b1701@45.87.107.24:27656,e726816f42831689eab9378d5d577f1d06d25716@169.155.46.27:26656,b90fcf4e43c0ff1f3c921698001828c93d6252e1@158.69.125.73:11256,35ecbcf9d8377ca2298cbe7a81eb57e520eb2154@152.53.33.96:26656,d3adcf9eee8665ee2d3108f721b3613cdd18c3a3@23.227.223.49:26656,9e6916423eaa4302127a0b7cb518ead4f8b98fd8@89.109.112.42:30656,e1b058e5cfa2b836ddaa496b10911da62dcf182e@164.152.161.227:26656,d4fedcd6918becd7804e7ccaad3d71237edfbb46@144.76.92.22:10656,0b209dd07b07e4754b8763a2cde80eb02a87bee5@65.109.97.51:26656,5ad3d484730844e66f15926c4fcc006c77b53ddd@88.99.137.151:26656,11024dd977b88f92432dd27bb671c8ab39caa511@65.21.15.238:27656,2ff3c369e3acdabbc371ee462cdf5c9d45a0c582@178.79.157.65:26656,4a89ad49b77cb751f02825f21b95c77b7bdb8e27@107.155.98.206:60856,e28ee47043a193f67fa9598a47a32494c5382a12@164.92.105.245:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.atomone/config/config.toml
```
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025uatone,0.225uphoton\"|" $HOME/.atomone/config/app.toml
```

### Prunning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.atomone/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.atomone/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.atomone/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.atomone/config/app.toml
```
### Indexer Off
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.atomone/config/config.toml
```
### Service
```
sudo tee /etc/systemd/system/atomoned.service > /dev/null << EOF
[Unit]
Description=atomone
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.atomone"
Environment="DAEMON_NAME=atomoned"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.atomone/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo tee /etc/systemd/system/atomoned.service > /dev/null <<EOF
[Unit]
Description=atomone
After=network-online.target

[Service]
User=$USER
ExecStart=$(which atomoned) start
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
sudo systemctl enable atomoned
```
```
sudo systemctl restart atomoned
```
```
sudo journalctl -u atomoned -f -o cat
```
### Sync
```
atomoned status 2>&1 | jq .SyncInfo
```
### Add wallet
```
atomoned keys add wallet --recover
```
### Balances
```
atomoned q bank balances $(atomoned keys show wallet -a)
```
### Validator
```
atomoned tx staking create-validator \
--amount=2000000000uatone \
--pubkey=$(atomoned tendermint show-validator) \
--moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Stake Provider & IBC Relayer" \
--chain-id=atomone-1 \
--commission-rate="0.02" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.02" \
--min-self-delegation=1 \
--from=wallet \
--gas=auto
```
### Edit
```
atomoned tx staking edit-validator \
--new-moniker="Vinjan.Inc" \
--identity="7C66E36EA2B71F68" \
--website="https://service.vinjan.xyz" \
--details="Stake Provider & IBC Relayer" \
--chain-id=atomone-1 \
--commission-rate="0.1" \
--from=wallet \
--gas-adjustment=1.2 \
--gas-prices="0.025uatone" \
--gas=auto
```

### Delegate
```
atomoned tx staking delegate $(atomoned keys show wallet --bech val -a) 1000000uatone --from wallet --chain-id atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.1uphoton"
```
### WD Commission
```
atomoned tx distribution withdraw-rewards $(atomoned keys show wallet --bech val -a) --commission --from wallet --chain-id atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.1uphoton"
```
### Vote
```
atomoned tx gov vote 10 yes --from wallet --chain-id atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.1uphoton""
```

### Own Peer
```
echo $(atomoned tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.atomone/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
### Connect Peer
```
curl -sS http://localhost:15657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### Send
```
atomoned tx bank send wallet atone14m0n559xdj00qwvp6ck0xesprrq26kgp75j0zw 10000uatone --from=wallet --chain-id=atomone-1 --gas-adjustment=1.2 --gas=auto --gas-prices="0.225uphoton""
```

### Delete
```
sudo systemctl stop atomoned
sudo systemctl disable atomoned
sudo rm /etc/systemd/system/atomoned.service
sudo systemctl daemon-reload
rm -f $(which atomoned)
rm -rf .atomone
rm -rf atomone
```




