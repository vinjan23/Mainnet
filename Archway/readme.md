### Package
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
git clone https://github.com/archway-network/archway.git
cd archway
git checkout v1.0.0
make install
```

### Init
```
MONIKER=
```
```
archwayd init $MONIKER --chain-id archway-1
archwayd config chain-id archway-1
archwayd config keyring-backend file
```

### pORT
```
PORT=34
archwayd config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.archway/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.archway/config/app.toml
```

### gENESIS
```
wget -O genesis.json https://snapshots.polkachu.com/genesis/archway/genesis.json --inet4-only
mv genesis.json ~/.archway/config
```

### Seed Peer Gas
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0aarch\"|" $HOME/.archway/config/app.toml
sed -i -e "s|^seeds *=.*|seeds = \"ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:11556\"|" $HOME/.archway/config/config.toml
PEERS=cb6ae22e1e89d029c55f2cb400b0caa19cbe5523@107.6.2.30:32640,264991b3fffac4c1cbc46d12a52a384f5554d0d5@35.228.95.81:26656,a4b739fa1eaccea583ee9645c5c7c3627a64266e@95.217.229.113:26656,fc5030b85b88aef75b61d6b18ae436a06001cdf3@178.63.184.130:26656,7e630475b43c9c7e648a0b1369b5811f8716de51@162.55.134.61:26656,ba48156e588d2247fdedd305e82c721508ebc701@34.159.46.155:26656,aa70d60e3c94780d7362b2c2216cd1db9596ab8f@5.181.190.135:26656,9dc379e8598040b0d8737db3654a914592ae21aa@95.214.55.56:26656,964e38899d4cfdeb7dbfa5af778416d934f09284@65.108.238.166:11556,717f6a9ff6aa7f75d663aa8c12df233391e74005@52.30.142.213:26656,661d340d5743d9cb8dd8f50962c13ebe255f8a60@185.144.99.38:26656,93750f4d48cfd8306307f968843f4ade0e7c4b95@35.224.91.64:26656,9d6676b51c1be62f0d20c3083ee054ca06779793@103.180.28.100:26656,aae23a12fa00ec5c0b91280ee5fac286d27118e3@81.0.220.94:25556,13a6ce69a00730db268c89d8aa7751f9e346662d@51.79.102.122:26656,c1897f4fb4103917fac7987c5e945937e35d70e8@143.110.128.132:26656,e7a0aeb40e2595e4e9500d7ebf088a762b2d0e6b@5.75.232.32:26656,6a47b42564eee3bf7d5e6fe0b0c2b8d530fab2b2@51.79.177.229:26661,91b78dd3cec32d505cb1d810994b771ebfa586b5@195.189.96.106:37656,4725bdd693175d4bc1e65782b2d62ee6026a5136@5.9.106.214:20156,e3ec24b645c5131e28be8fe1ffac9322f2ca6496@51.159.98.175:16656,190966bcf6cdd77055f5404a1c5ff699cc59ee0f@162.246.20.74:36656,17c579988684ca167be22c59a0719715cb038422@5.9.100.26:3000,b0c6d2d344388be60d37ccb22a5f548ea56f7d97@136.243.1.82:28656,996a4e60bea02401787178cac264fddf23301921@65.109.20.54:11556,ac89d74a5903b0cf4ff2304e94f46e82af22651c@62.210.145.19:26656,47a823bb6a02d29516e5a8b10af76a51faecc849@15.164.30.130:13056,ebcdf639b8b6d54d014257de84b3775779e214ea@65.109.97.249:11556,a050613abadb936afd4fe4be52e6348e7c610929@136.38.13.212:25606,f292b1577fea4652444c5d86ecc64f6f64be0313@135.181.165.80:26656,6ed96badfb77f58a629f3fe69d5152b38a0e7ff4@65.108.78.88:26656,9b9094e9e054b38bcb30c52cd8f02b8bb8ae6d21@5.9.23.47:26656,5173214e9616c7513ff75d938e7ade92a5d7bcc2@148.113.159.22:11556,b7d8ca6f59fd7e7362eabada1bd0117915cf1cb6@185.52.52.30:46656,55054a0b113e35b6315225de57d70916996be3ab@207.246.112.229:15656,d66995c2ec5484af88f15fa484186b004dfc23b0@185.246.87.129:26666,922723573a95faddc6eebdede6a7717939394fa3@95.216.184.113:26656,5c4edb2581e71d574886565398069b291c78a5c6@51.77.57.28:3000,f60e619d22d5bacf2d6a5cc0c7f8ede8f2713737@131.153.202.81:54656,cf056209f3673ec35706a07ccbbee3a656bc60f7@162.19.73.9:26662,96f5cffdd9b3aec2d680c33760a147a7478c5232@46.4.68.113:21456,2c6517f82fa517276c5394a958e5b64f9bb3520e@209.159.148.90:60556,5de2fc29b2f5b3bc4b172505021d96438da280f2@34.133.135.231:26656,a0cb55dd87938cd8c6bed5a8795e594544782613@202.61.239.140:26656,fb5191a8123666422fefea8e5e2a05f1e0a1af88@141.95.97.21:37656,aaec8e923b77b9e2f79a9cecfeb77a9dfea2dacf@141.94.139.219:26656,80a947787f6d13d00d54c29311dd2dead564f991@62.84.113.139:26656,b81d0645c8576b8b23d89c49f83a54574f5cff46@38.242.231.185:26656,da90031d838fb687d04753d92326ab8387b5d305@77.120.115.156:26656,7527ac22ed20e4e136d0d045202e31364b2453b2@211.216.47.217:26656,5cbc6ab1c653da4e8359aff775321945be7d9c9e@125.131.181.23:26656,f827b27d415975f09609c67b23bfeac7a3158c1d@45.33.67.94:26656,8f64a0af04c45ea10091a2e65996fbd0ca8134b7@125.131.181.24:26656,6909939c3c1f9237d3dd6744a8aaa0c7672a06bd@142.93.214.244:26656,9cb0b529c217fc1f92ca8ee4b32e581d01d8184d@152.32.226.174:26656,ec8c242651733a553fecee53011abada2a54a730@141.94.193.28:42656,ed708819fef699b9afc46f999ba5b135f82142b1@138.201.127.91:26694,ec92976ad3abd3fd32f25685e801671b129cc9aa@185.144.99.36:16656,f1d0c2cf4ba42e3ce725cc8e7acde309c7f1643c@35.193.197.39:26656,84a71465f19f5ab3ca3a30b6bb1848d3acd3bd59@54.215.94.36:13056,4cb619bf7aad1da2dea6a929904f810bc057f467@194.36.145.127:26656,b308dda41e4db2ee00852d91846f981c49943d46@161.97.96.91:46656,f1b210360e2df8242cbbd9a54662abfd1d6a9faf@136.243.67.189:11556,b071ffe1a75ea68698d664890cbdff4aa364aa58@195.189.96.118:37656,1bb2d18c7acd50a9f37e1e6c696805929d1c6147@142.132.248.34:11556,3ba7bf08f00e228026177e9cdc027f6ef6eb2b39@35.232.234.58:26656,f7c63fc3a57f53c76915275dce1b9d56e782c2db@109.205.180.81:26666,67a3b05b256c1d3faac0b52d178e8b3a94bafeac@65.109.70.100:21156,0ea534831ff20e6585d3de2df4fd19f16a4332ab@82.146.52.221:26656,a0f159294571f4cac529be11c0c9b3deca5fc6b5@65.108.6.45:56656,da2747dec4c672aef5ff07f7755c7ca0015f604a@57.128.96.155:11556,5cc2f879e5986b0f9b2ca259e181e17a409ed074@65.108.75.174:44656,aa8b4d0b1ed7f1bbd1943c015703bfd7e906a2ef@65.109.103.214:26656,67c302027f6a5364c776810d830e1d936bdf07e6@84.203.117.234:26656,5a46d12b3dfc7f5b2481296c3b3b289bfb06fdcf@94.250.203.6:21656,0aac5f456faf1c603fd9811663a967607ac04f0e@176.9.125.13:2120,47dc5221ee5e1bdd1a8d51093be5d25c4c0c8e95@51.195.6.227:26662,057e70433734943e2700973710c3cdcba1873fad@142.44.213.82:1410,e249fa236422b005cd8910062b2d8329899dc731@162.19.169.119:26656,0bb5727df4719c50f2efd8fbb87777413786fa69@65.109.54.222:26656,7a2345a2e01f27576b3463a35e3b83f666d191d9@204.93.241.110:27657,079d146aa7bbcee8558d2c658888476e3be69f7a@95.217.40.230:29666,a0eeed8ee23af8c546df55a177ec60661ab9ddc6@144.76.40.53:11556,7c144e7eff4866392d79c550915a9375e9d56d8a@135.181.58.28:26656,6a0537244e235c47561961ccd8d57bd38d173387@162.19.95.240:46656,fecec0a93c674b65b1de7a2e7b5b6606a4add270@95.217.117.99:26656,09cd985b8a747bae279f16b72ccdc5cba659a13a@159.69.184.48:26656,49aa4097ae141c54816e42159af23290f2b26119@142.132.248.138:26816,d9bfa29e0cf9c4ce0cc9c26d98e5d97228f93b0b@65.109.88.38:15656,6b142f5146b6a486027c857015279684837c551d@198.244.176.206:28656,a61ded98a0cc22c3dd18db1f7de256ed759edb44@103.234.71.245:26656,0ea83899eb8ec647214e2626ab305a27bdf12128@51.89.173.96:42656,14d3c81df939e4e655896ff627c65269d9470aa6@141.164.38.26:10003,c9916ba53c36fd69a4d4ee6256e2d48d02dfb7f2@78.47.156.105:26656,9f79f70679318acf1baef1917c741b4886ae2c82@37.187.144.187:29656,6c7026b70650eb3abc9d4166396b9d04c5591843@57.128.98.12:10003,44dd6f38bf6b1f327f60b8bfbbd543a2fd909778@66.85.156.102:56656,f752c2e456294ce267580bd890b99828271f8022@142.132.194.157:26756,a81667d4ed0352d63f9c7a697cf5647a3c115de1@15.235.115.152:10005,95cab6996672c6e524020dc474e1e063552c228d@65.108.139.20:36656,dc29cb236d02ea32afac900fe3592f4c4f40064f@65.109.53.22:42656,3bc337e84829c066cb1f8f89a1c96334b3abc700@162.55.1.176:26656,1a43f7c9d9f259576d13d30bebb249876fe3ee59@198.244.167.22:2120,359c6929e126ad98baa326e417a49e048967230f@167.235.132.251:26656,f630737525dd1d99d8bb7822f6f30a2a61fd8172@23.88.51.134:26656,54f2a10bd55206ad4e7f020e7fde2b136d3ad97d@169.150.240.74:37656,bd00f00c970363d4ad456cfcfa53bc0e8d803471@195.201.222.82:27002
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.archway/config/config.toml
```

### Prunning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.archway/config/app.toml
```

### Indexer
```
sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.archway/config/config.toml
```

### Service
```
sudo tee /etc/systemd/system/archwayd.service << EOF
[Unit]
Description=archway-mainnet
After=network-online.target
#
[Service]
User=$USER
ExecStart=$(which archwayd) start
RestartSec=3
Restart=on-failure
LimitNOFILE=65535
#
[Install]
WantedBy=multi-user.target
EOF
```

### Star
```
sudo systemctl daemon-reload
sudo systemctl enable archwayd
sudo systemctl restart archwayd
sudo journalctl -u archwayd -f -o cat
```

### Sync
```
archwayd status 2>&1 | jq .SyncInfo
```

### Log
```
sudo journalctl -u archwayd -f -o cat
```

### Wallet
```
archwayd keys add wallet --recover
```

### Balance
```
archwayd q bank balances $(archwayd keys show wallet -a)
```

### Validator
```
archwayd tx staking create-validator \
--amount 4500000000000000000aarch \
--pubkey $(archwayd tendermint show-validator) \
--moniker "vinjan" \
--identity "7C66E36EA2B71F68" \
--details "🎉Proffesional Stake & Node Validator🎉" \
--website "https://service.vinjan.xyz" \
--chain-id archway-1 \
--commission-rate 0.1 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--from wallet \
--gas-adjustment 1.4 \
--fees ‎900000000000aarch \
-y
```
‎900000000000
1500000000000
