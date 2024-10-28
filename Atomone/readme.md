### Binary
```
cd $HOME
git clone https://github.com/atomone-hub/atomone.git
cd atomone
git checkout v1.0.0
make install
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
wget -O $HOME/.atomone/config/genesis.json https://snapshots.whenmoonwhenlambo.money/atomone-1/genesis.json
```
### Addrbook
```
wget -O $HOME/.atomone/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Atomone/addrbook.json
```

### Seed Peers
```
seeds=""
sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.atomone/config/config.toml
peers="2ff3c369e3acdabbc371ee462cdf5c9d45a0c582@178.79.157.65:26656,d4fedcd6918becd7804e7ccaad3d71237edfbb46@144.76.92.22:10656,608b9ddafe16715e05563d8cd40d703b71a6e6a5@162.55.103.20:43656,11024dd977b88f92432dd27bb671c8ab39caa511@65.21.15.238:27656,9a2104250620518e94650bda45ca4bf7a40eae14@92.255.196.146:26656,6d659f88556185baa8b8aab70659ff8489bc71d8@184.107.110.20:17900,352a74c5d34bf10d78bc1a4c2d0cde9ad7de30e3@136.52.63.107:26656,8189bbd3888f1b963a1de6399a16bd1186760912@15.235.115.156:17900,1728955056b6aa8ee8d9c4cd41cd1eeeb1474462@136.38.55.33:26656,5ad3d484730844e66f15926c4fcc006c77b53ddd@88.99.137.151:26656,2c02f0e92e00a7fdacdfafb1919b3424047b1701@45.87.107.24:27656,0d54eb13f795a07cfacfc5fe963b8dc27b84fc94@135.181.237.86:26656,caa0b10601fc6f2b974c5111c54820ac44b356de@65.109.123.86:26656,35ecbcf9d8377ca2298cbe7a81eb57e520eb2154@152.53.33.96:26656,4a89ad49b77cb751f02825f21b95c77b7bdb8e27@107.155.98.206:60856,a31d85900f6562b3a8b275617359643a5607ed40@146.70.243.163:26656,e1b058e5cfa2b836ddaa496b10911da62dcf182e@164.152.161.227:26656,0b209dd07b07e4754b8763a2cde80eb02a87bee5@65.109.97.51:26656,ca1d8ab2fdc1cbff4c8283ddbcc8fd53a7d9a254@65.21.215.167:26656,9e6916423eaa4302127a0b7cb518ead4f8b98fd8@89.109.112.42:30656,e28ee47043a193f67fa9598a47a32494c5382a12@164.92.105.245:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.atomone/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0uatone\"|" $HOME/.atomone/config/app.toml
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
sudo systemctl restart atomoned
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

### Delegate
```
atomoned tx staking delegate $(atomoned keys show wallet --bech val -a) 1000000uatone --from wallet --chain-id atomone-1 --gas auto -y
```
### WD Commission
```
atomoned tx distribution withdraw-rewards $(atomoned keys show wallet --bech val -a) --commission --from wallet --chain-id atomone-1 --gas auto -y
```
### Own Peer
```
echo $(atomoned tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.atomone/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```
### Connect Peer
```
curl -sS http://localhost:15657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

```
sudo systemctl stop atomoned
atomoned tendermint unsafe-reset-all --home $HOME/.atomone --keep-addr-book
curl -L https://snapshots.whenmoonwhenlambo.money/atomone-1/atomone-1-snapshot-latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.atomone
sudo systemctl restart atomoned
journalctl -fu atomoned -o cat
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




