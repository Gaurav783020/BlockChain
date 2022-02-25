adminPrivateKey=$(ls ../artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore*)

function json_ccp {
    sed -e "s/\${adminPrivateKey}/$1/" \
        ./connection-profile/first-network-template.json
}

echo "$(json_ccp $adminPrivateKey)" > ./connection-profile/first-network.json
