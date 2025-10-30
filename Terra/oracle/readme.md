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
npm install
```
```
cd $HOME/oracle-feeder/price-server
```
```
screen -S npm
```
```
npm start
```
`cntrl A + D`
```
screen -R npm
```
```
screen -ls
```
```
screen -X -S <namascreen> quit
```
```
sudo tee /etc/systemd/system/price.service > /dev/null << 'EOF'
[Unit]
Description=Price Daemon
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/root/oracle-feeder/feeder
ExecStart=/usr/bin/npm start vote --\
  --data-source-url http://localhost:8532/latest \
  --lcd-url https://lcd.terra-classic.hexxagon.io \
  --chain-id columbus-5 \
  --validators terravaloper1dtujf3q0m8zg2tprv37vhdvzha9n6jlmcgpl8c \
  --password vinjan23
Restart=on-abort
Environment="ORACLE-FEEDER_PATH=/root/oracle-feeder/price-server/npm start"
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
npm start vote -- \
   --data-source-url http://localhost:8532/latest \
   --lcd-url https://lcd.terra-classic.hexxagon.io \
   --chain-id columbus-5 \
   --validators terravaloper1dtujf3q0m8zg2tprv37vhdvzha9n6jlmcgpl8c \
   --password vinjan23
```
```
terrad keys add feeder --keyring-backend os
```
```
terrad tx oracle set-feeder ... --from wallet --chain-id columbus-5 --fees 200000000uluna--gas=300000
```



