const { Gateway, Wallets, } = require('fabric-network');
const fs = require('fs');
const path = require("path")
const log4js = require('log4js');
const EventStrategies = require('fabric-network/lib/impl/event/defaulteventhandlerstrategies');
const logger = log4js.getLogger('query.js');
const util = require('util')
const constants = require('../config/constants.json')
const axios = require('axios');

const helper = require('./helper');

function login(req, callback) {

    axios.post(url, {
        "selector": {
            "phoneNumber": req.loginId
        }
    }).then((getResponse) => {
        data = getResponse.data.docs

    }).then(() => {
        if (data.length == 0) {
            result = {
                status: 'error',
                statusCode: 404,
                message: 'No record available',
                data: {}
            }
            callback(result)
        }
        else {
            delete data[0]._rev;
            delete data[0]["~version"];
            result = {
                status: 'success',
                statusCode: 200,
                message: 'Asset found',
                data: data[0]
            }
            callback(result)
        }
    }).catch((e) => {
        console.log(e);
        var result = {
            statusCode: 401,
            status: 'error',
            message: 'Error fetching Get',
            data: {}
        }
        callback(result)
    })
}

exports.login = login
