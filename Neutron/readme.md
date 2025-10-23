```
cd $HOME
rm -rf dungeonchain 
git clone https://github.com/neutron-org/neutron.git
cd neutron
git checkout v8.1.1
make install
```
```
mkdir -p $HOME/.neutrond/cosmovisor/genesis/bin
cp $HOME/go/bin/neutrond $HOME/.neutrond/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.neutrond/cosmovisor/genesis $HOME/.neutrond/cosmovisor/current -f
sudo ln -s $HOME/.neutrond/cosmovisor/current/bin/neutrond /usr/local/bin/neutrond -f
```
```
neutrond init Vinjan.Inc --chain-id neutron-1
```
```
PORT=185
sed -i -e "s%:26657%:${PORT}57%" $HOME/.neutrond/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}61%" $HOME/.neutrond/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%" $HOME/.neutrond/config/app.toml
```
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.005untrn\"|" $HOME/.neutrond/config/app.toml
```
```
sudo tee /etc/systemd/system/neutrond.service > /dev/null << EOF
[Unit]
Description=neutron
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.neutrond"
Environment="DAEMON_NAME=neutrond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.neutrond/cosmovisor/current/bin"
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable neutrond
```
```
sudo systemctl restart neutrond
sudo journalctl -u neutrond -f -o cat
```
```
neutrond status 2>&1 | jq .sync_info
```
```
sudo systemctl stop neutrond
neutrond tendermint unsafe-reset-all --home $HOME/.neutrond --keep-addr-book
```
