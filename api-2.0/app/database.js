const fs = require('fs');
const path = require("path")
const log4js = require('log4js');
const logger = log4js.getLogger('Database.js');
const util = require('util')
const axios = require('axios');
const constants = require('../config/constants.json')

const helper = require('./helper');
let check = {}

const checker = async (args) => {

    var phone = (args.body.phoneNumber != '' || args.body.phoneNumber != undefined) ? args.body.phoneNumber : null;
 
    try {
        await axios.post(constants.url.userurl, {
            "selector": {
                "phoneNumber": phone
            }
        })
            .then(async (response) => {
                let result1 = response.data.docs;
                if (result1.length == 0) {
                    check = {
                        status: true,
                        message: ''
                    }
                    return check
                }
                else {
                    check = {
                        status: false,
                        message: 'This Phone Number is already registered.'
                    }
                    return check
                }

            }, (error) => {
                logger.info("No Records Present as of now")
                logger.debug(error.message)
                check = {
                    status: true,
                    message: ''
                }
            });
    } catch (error) {
        logger.error(error);
    }

}

const database = async (args, fcn) => {

    try {
        console.log("====== Checking User in the System =======")

        switch (fcn) {
            case 'checkUser':
                await checker(args)
                return check;
        }
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return false
    }
}

exports.database = database