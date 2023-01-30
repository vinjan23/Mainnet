sudo apt update
sudo apt install snapd -y
sudo snap install lz4

sudo systemctl stop strided

wget -O stride_2135886.tar.lz4 https://snapshots.polkachu.com/snapshots/stride/stride_2135886.tar.lz4 --inet4-only

lz4 -c -d stride_2135886.tar.lz4  | tar -x -C $HOME/.stride
strided tendermint unsafe-reset-all --home $HOME/.stride --keep-addr-book
rm -v stride_2135886.tar.lz4

sudo systemctl restart strided
sudo journalctl -u strided -f --no-hostname -o cat
