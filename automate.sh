# sudo rm /artifacts/channel/create-certificate-with-ca/fabric-ca/ordererOrg/fabric-ca-server.db
# sudo rm /artifacts/channel/create-certificate-with-ca/fabric-ca/org1/fabric-ca-server.db

# sudo rm /artifacts/channel/create-certificate-with-ca/fabric-ca/org2/fabric-ca-server.db

# sudo rm /artifacts/channel/create-certificate-wisth-ca/fabric-ca/org3/fabric-ca-server.db

# sudo rm /artifacts/channel/create-certificate-with-ca/fabric-ca/org4/fabric-ca-server.db

echo "#############################################################################"

echo " Getting into Artifacts folder"

cd artifacts

echo " Removing volumes for Peers, Orderer, and CouchDB"
docker-compose down -v

echo " Getting into channel folder"
cd channel/

echo " Removing channel artifacts"
sudo rm -rf crypto-config

echo " Getting into CA folder"

cd create-certificate-with-ca/

echo " Removing CA artifacts"
sudo rm -rf fabric-ca

echo " Removing CA volumes"
docker-compose down -v
sleep 4

echo " Removing All Previous Docker images related to dev-network"

sudo docker images | grep "dev" | awk '{print $1}' | xargs docker rmi -f
sleep 4

echo " Running fresh CA docker containers"
docker-compose up -d
sleep 4

echo "Creating Channel Certificate"
./create-certificate-with-ca.sh
sleep 5
cd ..
pwd
sudo cp -a crypto-config/ordererOrganizations/example.com/msp/keystore/. crypto-config/ordererOrganizations/example.com/ca/
sudo cp -a crypto-config/peerOrganizations/org1.example.com/msp/keystore/. crypto-config/peerOrganizations/org1.example.com/ca/
sleep 2

echo " Creating Channel Artifacts"
./create-artifacts.sh
cd ..
sleep 6

echo " Running fresh docker containers for Orderer, Peers and CouchDB"
docker-compose up -d
sleep 10
cd ..

echo " Creating Channel"
./createChannel.sh
sleep 5

echo " Deploying CHaincode"
./deployChaincode.sh

cd api-2.0/config/

echo " Creating Node SDK connection Profile"
./generate-ccp.sh

cd ..

rm -r org4-wallet/
rm -r org3-wallet/
rm -r org2-wallet/
rm -r org1-wallet/

echo " Creating Explorer config"
cd ..
cd Explorer/

docker-compose down -v

./setExplorer.sh

docker-compose up -d

cd ..

echo " Starting Node Server"
OUTPUT=$(forever list)

count=${#OUTPUT}
if [[ $count -eq 47 ]]; then
    forever start api-2.0/app.js
    forever start api-2.0/Web/web.js
    forever start api-2.0/SMTP/smtp.js
else
    forever restart 0
    forever restart 1
    forever restart 2
fi

sleep 2
echo "Script Logs"
OUTPUT=$(forever list)
echo "${OUTPUT}"
