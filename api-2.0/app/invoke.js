const { Gateway, Wallets, TxEventHandler, GatewayOptions, DefaultEventHandlerStrategies, TxEventHandlerFactory } = require('fabric-network');
const fs = require('fs');
const EventStrategies = require('fabric-network/lib/impl/event/defaulteventhandlerstrategies');
const path = require("path")
const log4js = require('log4js');
const logger = log4js.getLogger('Invoke.js');
const util = require('util')
const axios = require('axios');

const constants = require('../config/constants.json')
const helper = require('./helper');
const { blockListener, contractListener } = require('./Listeners');



const invokeTransaction = async (fcn, args, username, org_name) => {
    try {
        const ccp = await helper.getCCP(org_name);

        const walletPath = await helper.getWalletPath(org_name);
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        let identity = await wallet.get(username);

        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, args.role)
            identity = await wallet.get(username);
            if (!identity) {
                console.log('Run the registerUser.js application before retrying');
                return;
            }
        }

        const connectOptions = {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }, eventHandlerOptions: {
                commitTimeout: 1000,
                strategy: DefaultEventHandlerStrategies.MSPID_SCOPE_ANYFORTX
            }
            // eventHandlerOptions: EventStrategies.NONE
        }

        const gateway = new Gateway();
        await gateway.connect(ccp, connectOptions);


        const network = await gateway.getNetwork(constants.channelName);

        const commonP = network.getContract('User', 'common')
        let result;

        switch (fcn) {
            case "registerUser":
                result = await commonP.submitTransaction('registerUser', JSON.stringify(args));
                break;
        }

        await gateway.disconnect();

        result = await JSON.parse(result.toString());
        return result;


    } catch (error) {

        var res = {
            status: 'error',
            statusCode: 500,
            message: "Fabric couldn't connect. ",
            data: {}
        }
        return JSON.stringify(res);
    }
}

exports.invokeTransaction = invokeTransaction;
