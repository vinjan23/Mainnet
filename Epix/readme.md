```
git clone https://github.com/EpixZone/EpixChain.git
cd EpixChain
git checkout v0.5.2
make install
```
```
mkdir -p $HOME/.epixd/cosmovisor/genesis/bin
cp $HOME/go/bin/epixd $HOME/.epixd/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.epixd/cosmovisor/genesis $HOME/.epixd/cosmovisor/current -f
sudo ln -s $HOME/.epixd/cosmovisor/current/bin/epixd /usr/local/bin/epixd -f
```
```
epixd init Vinjan.Inc --chain-id epix_1916-1
```
