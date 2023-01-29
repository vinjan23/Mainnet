sudo apt update
sudo apt install lz4 -y

sudo systemctl stop strided

cp $HOME/.stride/data/priv_validator_state.json $HOME/.stride/priv_validator_state.json.backup
strided tendermint unsafe-reset-all --home $HOME/.stride --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots2.nodejumper.io/stride/ | egrep -o ">stride-1.*\.tar.lz4" | tr -d ">")
curl https://snapshots2.nodejumper.io/stride/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.stride

mv $HOME/.stride/priv_validator_state.json.backup $HOME/.stride/data/priv_validator_state.json

sudo systemctl restart strided
sudo journalctl -u strided -f --no-hostname -o cat
