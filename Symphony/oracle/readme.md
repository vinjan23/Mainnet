```
cd $HOME
rm -rf symphony-oracle-voter
git clone https://github.com/cmancrypto/symphony-oracle-voter.git
cd symphony-oracle-voter
git checkout v1.0.0
```
```
nano $HOME/symphony-oracle-voter/.env
```
```
sudo apt install python3.11
```
```
sudo apt install python3.11-venv
```
```
python3 -m venv venv
```
```
source venv/bin/activate
```
```
pip install -r requirements.txt
```
```
deactivate
```
```
symphonyd tx oracle set-feeder symphony1h6897uqcuuv08p8qr55ql8y0j3zap8a2gjtsyu --from wallet --chain-id symphony-1 --fees 2500note
```
```
sudo tee /etc/systemd/system/oracle.service > /dev/null << EOF
[Unit]
Description=Symphony Oracle
After=network.target

[Service]
# Environment variables
Environment="SYMPHONYD_PATH=/root/symphony/build/symphonyd"
Environment="PYTHON_ENV=production"
Environment="LOG_LEVEL=INFO"
Environment="DEBUG=false"

# Service configuration
Type=simple
User=root
WorkingDirectory=/root/symphony-oracle-voter
ExecStart=/root/symphony-oracle-voter/venv/bin/python3 -u /root/symphony-oracle-voter/main.py
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable oracle.service
sudo systemctl start oracle.service
journalctl -u oracle.service -f
```
### Delete
```
sudo systemctl stop oracle.service
sudo systemctl disable oracle.service
sudo rm /etc/systemd/system/oracle.service
rm -rf symphony-oracle-voter
```

