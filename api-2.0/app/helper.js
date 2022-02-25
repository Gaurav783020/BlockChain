var { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const util = require('util');
const fs1 = require('fs-extra');
const constants = require('../config/constants.json')
let fetch = require('node-fetch');
const { log } = require('console');

const getCCP = async (org) => {
    let ccpPath = null;
    org == 'Org1' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-org1.json') : null
    org == 'Org2' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-org2.json') : null
    org == 'Org3' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-org3.json') : null
    org == 'Org4' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-org4.json') : null
    const ccpJSON = fs.readFileSync(ccpPath, 'utf8')
    const ccp = JSON.parse(ccpJSON);
    return ccp
}

const getCaUrl = async (org, ccp) => {
    let caURL = null
    org == 'Org1' ? caURL = ccp.certificateAuthorities['ca.org1.example.com'].url : null
    org == 'Org2' ? caURL = ccp.certificateAuthorities['ca.org2.example.com'].url : null
    org == 'Org3' ? caURL = ccp.certificateAuthorities['ca.org3.example.com'].url : null
    org == 'Org4' ? caURL = ccp.certificateAuthorities['ca.org4.example.com'].url : null
    return caURL
}

const getWalletPath = async (org) => {
    let walletPath = null
    org == 'Org1' ? walletPath = path.join(process.cwd(), 'org1-wallet') : null
    org == 'Org2' ? walletPath = path.join(process.cwd(), 'org2-wallet') : null
    org == 'Org3' ? walletPath = path.join(process.cwd(), 'org3-wallet') : null
    org == 'Org4' ? walletPath = path.join(process.cwd(), 'org4-wallet') : null
    return walletPath
}


const getAffiliation = async (org) => {
    // Default in ca config file we have only two affiliations, if you want ti use org3 ca, you have to update config file with third affiliation
    //  Here already two Affiliation are there, using i am using "org2.department1" even for org3
    // return org == "Org1" ? 'org1.department1' : 'org2.department1'
    // change in /artifacts/channel/create-certificate-with-ca for affiliation and register again
    switch (org) {
        case "Org1": return "org1.role"
        case "Org2": return "org2.role"
        case "Org3": return "org3.role"
        case "Org4": return "org4.role"
    }
}

const getRegisteredUser = async (username, userOrg, role) => {
    let ccp = await getCCP(userOrg)

    const caURL = await getCaUrl(userOrg, ccp)
    console.log("ca url is ", caURL)
    const ca = new FabricCAServices(caURL);

    const walletPath = await getWalletPath(userOrg)
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const userIdentity = await wallet.get(username);
    if (userIdentity) {
        console.log(`An identity for the user ${username} already exists in the wallet`);
        var response = {
            message: username + ' enrolled Successfully',
        };
        return response
    }

    // Check to see if we've already enrolled the admin user.
    let adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
        console.log('An identity for the admin user "admin" does not exist in the wallet');
        await enrollAdmin(userOrg, ccp);
        adminIdentity = await wallet.get('admin');
        console.log("Admin Enrolled Successfully")
    }

    // build a user object for authenticating with the CA
    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');
    let secret;
    try {
        // Register the user, enroll the user, and import the new identity into the wallet.
        // secret = await ca.register({ affiliation: await getAffiliation(userOrg), enrollmentID: username, role: 'client' }, adminUser);
        secret = await ca.register({ affiliation: await getAffiliation(userOrg), enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: role, ecert: true }] }, adminUser);

    } catch (error) {
        return error.message
    }

    // const enrollment = await ca.enroll({ enrollmentID: username, enrollmentSecret: secret });
    const enrollment = await ca.enroll({ enrollmentID: username, enrollmentSecret: secret, attr_reqs: [{ name: 'role', optional: false }] });

    let x509Identity = {
        credentials: {
            certificate: enrollment.certificate,
            privateKey: enrollment.key.toBytes(),
        },
        mspId: `${userOrg}MSP`,
        type: 'X.509',
    };
    await wallet.put(username, x509Identity);
    console.log(`Successfully registered and enrolled admin user ${username} and imported it into the wallet`);

    var response = {
        message: username + ' enrolled Successfully',
    };
    return response
}

const isUserRegistered = async (username, userOrg) => {
    const walletPath = await getWalletPath(userOrg)
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const userIdentity = await wallet.get(username);
    if (userIdentity) {
        console.log(`An identity for the user ${username} exists in the wallet`);
        return true
    }
    return false
}

const findId = async (username) => {

    let array = ['Org1', "Org2", "Org3", "Org4"]

    for (var i = 0; i < 4; i++) {
        const walletPath = await getWalletPath(array[i])
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        const userIdentity = await wallet.get(username);

        if (userIdentity) {
            console.log(`An identity for the user ${username} exists in the wallet`);
            let result = {
                status: true,
                Org: array[i]
            }
            return result
        }
        else if (array[i] == 'Org4') {
            let result = {
                status: false,
                Org: ''
            }
            return result
        }
    }

}


const getCaInfo = async (org, ccp) => {
    let caInfo = null
    org == 'Org1' ? caInfo = ccp.certificateAuthorities['ca.org1.example.com'] : null
    org == 'Org2' ? caInfo = ccp.certificateAuthorities['ca.org2.example.com'] : null
    org == 'Org3' ? caInfo = ccp.certificateAuthorities['ca.org3.example.com'] : null
    org == 'Org4' ? caInfo = ccp.certificateAuthorities['ca.org4.example.com'] : null
    return caInfo
}

const enrollAdmin = async (org, ccp) => {
    console.log('calling enroll Admin method')
    try {
        const caInfo = await getCaInfo(org, ccp) //ccp.certificateAuthorities['ca.org1.example.com'];
        const caTLSCACerts = caInfo.tlsCACerts.pem;
        const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);

        // Create a new file system based wallet for managing identities.
        const walletPath = await getWalletPath(org) //path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const identity = await wallet.get('admin');
        if (identity) {
            console.log('An identity for the admin user "admin" already exists in the wallet');
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        // console.log("Enrollment object is : ", enrollment)
        let x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: `${org}MSP`,
            type: 'X.509',
        };

        await wallet.put('admin', x509Identity);
        console.log('Successfully enrolled admin user "admin" and imported it into the wallet');
        return
    } catch (error) {
        console.error(`Failed to enroll admin user "admin": ${error}`);
    }
    console.error(`Failed to enroll admin user "admin": ${error}`);
}


const registerAndGerSecret = async (username, userOrg) => {
    let ccp = await getCCP(userOrg)

    const caURL = await getCaUrl(userOrg, ccp)
    const ca = new FabricCAServices(caURL);

    const walletPath = await getWalletPath(userOrg)
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const userIdentity = await wallet.get(username);
    if (userIdentity) {
        console.log(`An identity for the user ${username} already exists in the wallet`);
        var response = {
            message: username + ' enrolled Successfully',
        };
        return response
    }

    // Check to see if we've already enrolled the admin user.
    let adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
        console.log('An identity for the admin user "admin" does not exist in the wallet');
        await enrollAdmin(userOrg, ccp);
        adminIdentity = await wallet.get('admin');
        console.log("Admin Enrolled Successfully")
    }

    // build a user object for authenticating with the CA
    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');
    let secret;
    try {
        // Register the user, enroll the user, and import the new identity into the wallet.
        secret = await ca.register({ affiliation: await getAffiliation(userOrg), enrollmentID: username, role: 'client' }, adminUser);
        // const secret = await ca.register({ affiliation: 'org1.department1', enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: 'approver', ecert: true }] }, adminUser);

    } catch (error) {
        return error.message
    }

    var response = {
        message: username + ' enrolled Successfully',
        secret: secret
    };
    return response

}



exports.getRegisteredUser = getRegisteredUser

module.exports = {
    getCCP: getCCP,
    getWalletPath: getWalletPath,
    getRegisteredUser: getRegisteredUser,
    isUserRegistered: isUserRegistered,
    registerAndGerSecret: registerAndGerSecret,
    enrollAdmin: enrollAdmin,
    findId: findId
}
