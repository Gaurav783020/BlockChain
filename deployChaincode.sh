export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
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

Channel="channel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
SEQUENCE="1"
CC1_SRC_PATH="./Chaincode/User/"
CC1_NAME="User"

export Channel

packageChaincode() {
    rm -rf ${CC1_NAME}.tar.gz
    echo " "
    echo " ***************************************************************** "
    echo " ====================== Packaging Chaincode ====================== "
    echo " ***************************************************************** "
    echo " "

    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC1_NAME}.tar.gz \
        --path ${CC1_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC1_NAME}_${VERSION}

    echo "All Chaincode Packaged"

    echo " "
    echo " ***************************************************************** "
    echo " ===================== Chaincode is packaged ===================== "
    echo " ***************************************************************** "
    echo " "
}
# packageChaincode

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

    echo " "
    echo " ***************************************************************** "
    echo " =================== Querying is Completed ==================== "
    echo " ***************************************************************** "
    echo " "

    export PACKAGE_ID1
}

approveForMyOrg() {

    echo " "
    echo " ***************************************************************** "
    echo " ==================== Approving From Org's ==================== "
    echo " ***************************************************************** "
    echo " "

    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $Channel --name ${CC1_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID1} --sequence ${SEQUENCE} --signature-policy "OR ('Org1MSP.peer')"
    # set +x

    echo "===================== Patient chaincode approved from org 1 ===================== "

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
        --cafile $ORDERER_CA --name ${CC1_NAME} --version ${VERSION} \
        --init-required --sequence ${VERSION} --output json --signature-policy "OR ('Org1MSP.peer')"
    echo "===================== checking commit readyness from org 1 ===================== "

    echo "===================== checking commit readyness from org 2 ===================== "
    echo " "
    echo " ***************************************************************** "
    echo " ================ Checked Commit Readiness  ================ "
    echo " ***************************************************************** "
    echo " "

}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $Channel --name ${CC1_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER1_ORG1_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required --signature-policy "OR ('Org1MSP.peer')"

    echo "===================== chaincode committed from org 1 ===================== "

    echo "===================== chaincode committed from org 1 ===================== "
}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $Channel --name ${CC1_NAME}
    echo "===================== Query Committed ===================== "
}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $Channel -n ${CC1_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --isInit -c '{"Args":[]}'

    echo "===================== chaincode invoke from org 1 ===================== "
}

# chaincodeInvokeInit

# Run this function if you add any new dependency in chaincode
# presetup

packageChaincode
installChaincode
queryInstalled
approveForMyOrg
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
