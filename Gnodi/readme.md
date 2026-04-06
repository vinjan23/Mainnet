```
cd $HOME
https://github.com/gnodi-network/gnodi.git
cd gnodi
git checkout v1.0.1
make install

mkdir -p $HOME/.gnodi/cosmovisor/genesis/bin
cp $HOME/go/bin/gnodid $HOME/.ggnodi/cosmovisor/genesis/bin/

sudo ln -s $HOME/.gnodi/cosmovisor/genesis $HOME/.gnodi/cosmovisor/current -f
sudo ln -s $HOME/.gnodi/cosmovisor/current/bin/gnodid /usr/local/bin/gnodid -f


gnodid version --long | grep -e commit -e version

wget -O $HOME/.gnodi/config/genesis.json https://raw.githubusercontent.com/gnodi-network/genesis-mainnet/refs/heads/main/genesis.json

gnodidf init Vinjan.Inc --chain-id gnodi

PORT=155
sed -i -e "s%:26657%:${PORT}57%" $HOME/.gnodi/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.gnodi/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:8080%:${PORT}80%; s%:9090%:${PORT}90%; s%:9091%:${PORT}91%" $HOME/.gnodi/config/app.toml

PORT=105
sed -i -e "s%:26657%:${PORT}57%" $HOME/.gnodi/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.gnodi/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.gnodi/config/app.toml

sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
$HOME/.gnodi/config/app.toml

sed -i 's|^indexer *=.*|indexer = "null"|' $HOME/.gnodi/config/config.toml

sudo tee /etc/systemd/system/gnodid.service > /dev/null << EOF
[Unit]
Description=gnodi
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.gnodi"
Environment="DAEMON_NAME=gnodid"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.gnodi/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable gnodid
sudo systemctl restart gnodid
sudo journalctl -u gnodid -f -o cat

``
