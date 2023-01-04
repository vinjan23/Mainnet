sudo systemctl stop planqd

cp $HOME/.planqd/data/priv_validator_state.json $HOME/.planqd/priv_validator_state.json.backup
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book

SNAP_RPC="https://rpc.planq.network:443" \
SNAP_RPC2="https://rpc.planq.network:443" 
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
PEERS=$(curl -sL https://raw.githubusercontent.com/planq-network/networks/main/mainnet/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -)
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.planqd/config/config.toml
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.planqd/config/config.toml

mv $HOME/.planqd/priv_validator_state.json.backup $HOME/.planqd/data/priv_validator_state.json
sudo systemctl restart planqd
sudo journalctl -u planqd -f -o cat
