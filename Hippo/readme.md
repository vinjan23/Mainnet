```
sudo systemctl restart hippod
sudo journalctl -u hippod -f -o cat
```
```
hippod status 2>&1 | jq .sync_info
```
```
hippod keys add wallet
```
