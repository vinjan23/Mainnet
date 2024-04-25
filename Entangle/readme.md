```
wget -O $HOME/.entangled/config/genesis.json https://raw.githubusercontent.com/vinjan23/Mainnet/main/Entangle/genesis.json
```
```
wget -O $HOME/.entangled/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Mainnet/main/Entangle/addrbook.json
```
```
sudo apt install lz4 -y
sudo systemctl stop entangled
entangled tendermint unsafe-reset-all --home $HOME/.entangled --keep-addr-book
curl -L https://snapshot.vinjan.xyz./entangle/entangle-snapshot-20240425.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.entangled
sudo systemctl restart entangled
journalctl -fu entangled -o cat
```
