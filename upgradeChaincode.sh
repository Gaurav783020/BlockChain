export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
export PEER1_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
export PEER1_ORG3_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt
export PEER0_ORG4_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export PEER1_ORG4_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org4.example.com/peers/peer1.org4.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/
export PRIVATE_DATA_CONFIG=${PWD}/private-data/collection_config.json

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForOrg1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051

}

setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

setGlobalsForPeer1Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:12051
    
}

setGlobalsForPeer0Org4(){
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=localhost:13051
    
}

setGlobalsForPeer1Org4(){
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=localhost:14051
    
}
setGlobalsForPeer0Org1
peer lifecycle chaincode querycommitted -C "channel" >&temp.txt
versionno=$(awk -F ',' 'NR!=1{print $2}' temp.txt | cut -d ' ' -f 3) 
IFS=' '
read -ra arr <<< "$versionno"
versionno=$((${arr[0]} + 1))
echo ${versionno}
Channel="channel"
CC_RUNTIME_LANGUAGE="node"
VERSION=${versionno}
SEQUENCE=${versionno}
CC1_SRC_PATH="./Chaincode/patient/"
CC1_NAME="patient"
CC2_SRC_PATH="./Chaincode/doctor/"
CC2_NAME="doctor"
CC3_SRC_PATH="./Chaincode/appointment/"
CC3_NAME="appointment"

export Channel

packageChaincode() {
    rm -rf ${CC1_NAME}.tar.gz
    rm -rf ${CC2_NAME}.tar.gz
    rm -rf ${CC3_NAME}.tar.gz

    echo " "
    echo " ***************************************************************** "
    echo " ====================== Packaging Chaincode ====================== "
    echo " ***************************************************************** "
    echo " "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC1_NAME}.tar.gz \
        --path ${CC1_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC1_NAME}_${VERSION}

    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC2_NAME}.tar.gz \
        --path ${CC2_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC2_NAME}_${VERSION}

    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC3_NAME}.tar.gz \
        --path ${CC3_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC3_NAME}_${VERSION}

    echo "All Chaincode Packaged"

    echo " "
    echo " ***************************************************************** "
    echo " ===================== Chaincode is packaged ===================== "
    echo " ***************************************************************** "
    echo " "
}

installChaincode() {

    echo " "
    echo " ***************************************************************** "
    echo " ==================== Installing  Chaincode ==================== "
    echo " ***************************************************************** "
    echo " "

    echo " Installing on Peer 0 Org 1"
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC1_NAME}.tar.gz
    echo "===================== Patient Chaincode is installed on peer0.org1 ===================== "

    echo " Installing on Peer 1 Org 1"
    setGlobalsForPeer1Org1
    peer lifecycle chaincode install ${CC1_NAME}.tar.gz
    echo "===================== Patient Chaincode is installed on peer1.org1 ===================== "

    echo " Installing on Peer 0 Org 2"
    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC2_NAME}.tar.gz
    echo "===================== Doctor Chaincode is installed on peer0.org2 ===================== "

    echo " Installing on Peer 1 Org 2"
    setGlobalsForPeer1Org2
    peer lifecycle chaincode install ${CC2_NAME}.tar.gz
    echo "===================== Doctor Chaincode is installed on peer1.org2 ===================== "

    echo " Installing on Peer 0 Org 1"
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC3_NAME}.tar.gz
    echo "===================== Appointment Chaincode is installed on peer0.org1 ===================== "

    echo " Installing on Peer 1 Org 1"
    setGlobalsForPeer1Org1
    peer lifecycle chaincode install ${CC3_NAME}.tar.gz
    echo "===================== Appointment Chaincode is installed on peer1.org1 ===================== "

    echo " Installing on Peer 0 Org 2"
    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC3_NAME}.tar.gz
    echo "===================== Appointment Chaincode is installed on peer0.org2 ===================== "

    echo " Installing on Peer 1 Org 2"
    setGlobalsForPeer1Org2
    peer lifecycle chaincode install ${CC3_NAME}.tar.gz
    echo "===================== Appointment Chaincode is installed on peer1.org2 ===================== "

    echo " "
    echo " ***************************************************************** "
    echo " =================== Chaincode is Installed ==================== "
    echo " ***************************************************************** "
    echo " "

}

queryInstalled() {

    echo " "
    echo " ***************************************************************** "
    echo " ===================== Querying Chaincode ===================== "
    echo " ***************************************************************** "
    echo " "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID1=$(sed -n "/${CC1_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID1}
    echo "===================== Query  successful on peer0.org1 on channel ===================== "

    setGlobalsForPeer1Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID1=$(sed -n "/${CC1_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID1}
    echo "===================== Query  successful on peer1.org1 on channel ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID2=$(sed -n "/${CC2_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID2}
    echo "===================== Query  successful on peer0.org2 on channel ===================== "

    setGlobalsForPeer1Org2
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID2=$(sed -n "/${CC2_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID2}
    echo "===================== Query  successful on peer1.org2 on channel ===================== "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID3=$(sed -n "/${CC3_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID3}
    echo "===================== Query  successful on peer0.org1 on channel ===================== "

    setGlobalsForPeer1Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID3=$(sed -n "/${CC3_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID3}
    echo "===================== Query  successful on peer1.org1 on channel ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID3=$(sed -n "/${CC3_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID3}
    echo "===================== Query  successful on peer0.org2 on channel ===================== "

    setGlobalsForPeer1Org2
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID3=$(sed -n "/${CC3_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID3}
    echo "===================== Query  successful on peer1.org2 on channel ===================== "

    echo " "
    echo " ***************************************************************** "
    echo " =================== Querying is Completed ==================== "
    echo " ***************************************************************** "
    echo " "

    export PACKAGE_ID1
    export PACKAGE_ID2
    export PACKAGE_ID3
}

approveForMyOrg() {

    echo " "
    echo " ***************************************************************** "
    echo " ==================== Approving From Org's ==================== "
    echo " ***************************************************************** "
    echo " "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $Channel --name ${CC1_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID1} --sequence ${SEQUENCE} --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== Patient chaincode approved from org 1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $Channel --name ${CC2_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID2} --sequence ${SEQUENCE} --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== Doctor chaincode approved from org 2 ===================== "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $Channel --name ${CC3_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID3} --sequence ${SEQUENCE} --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== Appointment chaincode approved from org 1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $Channel --name ${CC3_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID3} --sequence ${SEQUENCE} --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== Appointment chaincode approved from org 2 ===================== "

    echo " "
    echo " ***************************************************************** "
    echo " ==================== Approved From Org's ==================== "
    echo " ***************************************************************** "
    echo " "

}

checkCommitReadyness() {
    echo " "
    echo " ***************************************************************** "
    echo " ================= Check Commit Readiness ================= "
    echo " ***************************************************************** "
    echo " "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        -o localhost:7050 --channelID $Channel --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --name ${CC1_NAME} --version ${VERSION} \
        --init-required --sequence ${VERSION} --output json --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"
    echo "===================== checking commit readyness from org 1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode checkcommitreadiness \
        -o localhost:7050 --channelID $Channel --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --name ${CC2_NAME} --version ${VERSION} \
        --init-required --sequence ${VERSION} --output json --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"
    echo "===================== checking commit readyness from org 2 ===================== "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        -o localhost:7050 --channelID $Channel --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --name ${CC3_NAME} --version ${VERSION} \
        --init-required --sequence ${VERSION} --output json --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"
    echo "===================== checking commit readyness from org 1 ===================== "

    echo "===================== checking commit readyness from org 2 ===================== "
    echo " "
    echo " ***************************************************************** "
    echo " ================ Checked Commit Readiness  ================ "
    echo " ***************************************************************** "
    echo " "

}


commitChaincodeDefination() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $Channel --name ${CC1_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER1_ORG1_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== chaincode committed from org 1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $Channel --name ${CC2_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:10051 --tlsRootCertFiles $PEER1_ORG2_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== chaincode committed from org 1 ===================== "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $Channel --name ${CC3_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER1_ORG1_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required --signature-policy "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer')"

    echo "===================== chaincode committed from org 1 ===================== "
}

queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $Channel --name ${CC1_NAME}
    echo "===================== Query Committed ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode querycommitted --channelID $Channel --name ${CC2_NAME}
    echo "===================== Query Committed ===================== "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $Channel --name ${CC3_NAME}
    echo "===================== Query Committed ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode querycommitted --channelID $Channel --name ${CC3_NAME}
    echo "===================== Query Committed ===================== "
}

chaincodeInvokeInit() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $Channel -n ${CC1_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --isInit -c '{"Args":[]}'

    echo "===================== chaincode invoke from org 1 ===================== "

    setGlobalsForPeer0Org2
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $Channel -n ${CC2_NAME} \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --isInit -c '{"Args":[]}'

    echo "===================== chaincode invoke from org 2 ===================== "

    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $Channel -n ${CC3_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --isInit -c '{"Args":[]}'

    echo "===================== chaincode invoke from org 1 ===================== "
}

packageChaincode
installChaincode
queryInstalled
approveForMyOrg
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
