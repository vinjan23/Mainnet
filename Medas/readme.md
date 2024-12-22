### Binary
```
cd $HOME
wget https://github.com/oxygene76/medasdigital-2/releases/download/v1.0.0/medasdigitald
chmod +x medasdigitald
mv medasdigitald $HOME/go/bin/
```
```
rm /usr/lib/libwasmvm.x86_64.so
wget -P /usr/lib https://github.com/CosmWasm/wasmvm/releases/download/v2.1.2/libwasmvm.x86_64.so
sudo ldconfig
```
### Init
```
medasdigitald init Vinjan.Inc --chain-id medasdigital-2
```
```
medasdigitald version --long | grep -e commit -e version
```
### Port
```
sed -i.bak -e  "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:23657\"%" $HOME/.medasdigital/config/client.toml
```
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:23658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:23657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:23060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:23656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":23660\"%" $HOME/.medasdigital/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:23317\"%; s%^address = \"localhost:9090\"%address = \"localhost:23090\"%" $HOME/.medasdigital/config/app.toml
```
### Genesis
```
wget -O $HOME/.medasdigital/config/genesis.json https://raw.githubusercontent.com/oxygene76/medasdigital-2/refs/heads/main/genesis/mainnet/config/genesis.json
```
### Addrbook
```
wget -O $HOME/.medasdigital/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/refs/heads/main/Medas/addrbook.json
``` 

### PEER
```
peers="51ca3b0a3663af88566b32ecfd77948e55000bcc@88.205.101.195:26656,90be2e9f0a279372d2931e38f15025db9a847dbd@88.205.101.196:26656,0e567c9efe6e6d15f9b3257679398368c2ab04bb@88.205.101.197:26656,669d1b9f9c4bb99df594abaee4b13ae1b14d37a6@64.251.18.192:26656,cbfcd111ee19483dbbfed0919ac0d23119c5f0fe@67.207.180.166:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.medasdigital/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025umedas\"|" $HOME/.medasdigital/config/app.toml
```
### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.medasdigital/config/app.toml
```
### indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.medasdigital/config/config.toml
```
### service
```
sudo tee /etc/systemd/system/medasdigitald.service > /dev/null << EOF
[Unit]
Description=medasdigital
After=network-online.target
[Service]
User=$USER
ExecStart=$(which medasdigitald) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable medasdigitald
sudo systemctl restart medasdigitald
sudo journalctl -u medasdigitald -f -o cat
```
### Sync
```
medasdigitald status 2>&1 | jq .sync_info
```
### Wallet
```
medasdigitald keys add wallet
```
### Balances
```
medasdigitald  q bank balances $(medasdigitald keys show wallet -a)
```
### Validator
```
medasdigitald tendermint show-validator
```
```
nano /root/.medasdigital/validator.json
```
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"GA51Y2oJZoWREzWrjUmnsw3gvB2qpMGH2X5rKtb/djM="},
  "amount": "115000000umedas",
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
medasdigitald tx staking create-validator $HOME/.medasdigital/validator.json \
--from wallet \
--chain-id medasdigital-2 \
--gas-prices 0.025umedas \
--gas-adjustment 1.5 \
--gas auto
```





