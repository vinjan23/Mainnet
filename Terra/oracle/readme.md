```
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -- 
sudo apt-get install -y nodejs 
```
``` 
cd  $HOME
git clone https://github.com/classic-terra/oracle-feeder 
cd oracle-feeder 
git checkout v3.1.5
```
```
cd $HOME/oracle-feeder/price-server/config
```
``` 
cp default-sample.js default.js
```
``` 
nano default.js
```
```
cd $HOME/oracle-feeder/price-server 
```
```
sudo apt install nodejs 
```
``` 
node --version 
```
```
npm install
```
```
npm start
```
```
sudo tee /etc/systemd/system/price.service > /dev/null << EOF
[Unit] 
Description=Price Daemon 
After=network.target 
[Service] 
Type=simple 
User=root
WorkingDirectory=/root/oracle-feeder/price-server 
ExecStart=npm run start 
Restart=on-abort 
[Install] 
WantedBy=multi-user.target 
EOF
```
```
sudo systemctl daemon-reload 
sudo systemctl enable price.service
sudo systemctl restart price.service
journalctl -u price.service -f
```
```
terrad keys add feeder --keyring-backend os
```
```
terrad tx oracle set-feeder ... --from wallet --chain-id columbus-5 --fees 200000000uluna--gas=300000
```



