# Delete existing artifacts
rm genesis.block Org1MSPanchors.tx Org4MSPanchors.tx Org2MSPanchors.tx Org3MSPanchors.tx channel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "channel"
CHANNEL_NAME="channel"

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile Channel -configPath . -outputCreateChannelTx ./channel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for Org1MSP with Channel  ##########"
configtxgen -profile Channel -configPath . -outputAnchorPeersUpdate ./Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP