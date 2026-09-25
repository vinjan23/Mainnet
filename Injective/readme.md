```
cd $HOME
rm -rf injective
git clone https://github.com/InjectiveFoundation/injective-core injective
cd injective
git checkout v1.20.4-1789748350
make install
```
```
wget https://github.com/InjectiveFoundation/injective-core/releases/download/v1.20.4-1789748350/linux-amd64.zip
unzip -o linux-amd64.zip -d injective-v1.20.4
```
```
sudo mv $HOME/injective-v1.20.4/injectived /root/go/bin/
sudo mv injective-v1.20.4/peggo /usr/bin/peggo
sudo mv injective-v1.20.4/libwasmvm.x86_64.so /usr/lib/libwasmvm.x86_64.so
chmod +x /usr/bin/injectived /usr/bin/peggo
sudo ldconfig
```
```
injectived init Vinjan.Inc --chain-id injective-1
```
```
PORT=119
sed -i -e "s%:26657%:${PORT}57%" $HOME/.injectived/config/client.toml
sed -i -e "s%:26658%:${PORT}58%; s%:26657%:${PORT}57%; s%:6060%:${PORT}60%; s%:26656%:${PORT}56%; s%:26660%:${PORT}60%" $HOME/.injectived/config/config.toml
sed -i -e "s%:1317%:${PORT}17%; s%:9090%:${PORT}90%; s%:8545%:${PORT}45%; s%:8546%:${PORT}46%; s%:6065%:${PORT}65%" $HOME/.injectived/config/app.toml
```
```
sudo tee /etc/systemd/system/injectived.service > /dev/null <<EOF
[Unit]
Description=injective
After=network-online.target
[Service]
User=$USER
ExecStart=$(which injectived) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable injectived
```
```
sudo systemctl restart injectived
sudo journalctl -u injectived -f -o cat
```
```
injectived status 2>&1 | jq .sync_info
```
```
sudo systemctl stop injectived
injectived comet unsafe-reset-all --home $HOME/.injectived --keep-addr-book
```



