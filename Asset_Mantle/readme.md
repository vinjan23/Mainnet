### Update
```
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
```

### GO
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

### Binary
```
cd $HOME
rm -rf AssetMantle
git clone https://github.com/AssetMantle/node.git
cd AssetMantle
git checkout v0.3.1
make build
mkdir -p $HOME/.AssetMantle/cosmovisor/genesis/bin
mv build/mantleNode $HOME/.AssetMantle/cosmovisor/genesis/bin/
rm -rf build
ln -s $HOME/.AssetMantle/cosmovisor/genesis $HOME/.AssetMantle/cosmovisor/current
sudo ln -s $HOME/.AssetMantle/cosmovisor/current/bin/mantleNode /usr/local/bin/mantleNode
```

# Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```

### Set moniker
```
MONIKER=Your_NODENAME 
```

### Init
```
PORT=42
mantleNode config chain-id mantle-1
mantleNode init "$MONIKER" --chain-id mantle-1
manttleNode config keyring-backend file
manttleNode config node tcp://localhost:${PORT}657
```
