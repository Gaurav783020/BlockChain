'use strict';
const log4js = require('log4js');
const logger = log4js.getLogger('App.js');
const bodyParser = require('body-parser');
const http = require('http')
const util = require('util');
const express = require('express')
const app = express();
const expressJWT = require('express-jwt');
const jwt = require('jsonwebtoken');
const bearerToken = require('express-bearer-token');
const cors = require('cors');
const bcrypt = require('bcrypt');
let fetch = require('node-fetch');
const { lookup } = require('geoip-lite');
const saltRounds = 10;
var QRCode = require('qrcode')

const client = require('twilio')('ACe10cf27119f112c5d31886f4d6e2c896', '057d90d8a7c019b3207471a621a317be');
const constants = require('./config/constants.json')
const patient = require('./routes/patient/patient')
const doctor = require('./routes/doctor/doctor')
const querydata = require('./routes/query/query');
const appointment = require('./routes/appointment/appointment');
const mahadmin = require('./routes/mahadmin/mahadmin');

const host = process.env.HOST || constants.host;
const port = process.env.PORT || constants.port;


const helper = require('./app/helper')
const invoke = require('./app/invoke')
const qscc = require('./app/qscc')
const query = require('./app/query')
const database = require('./app/database');

app.options('*', cors());
app.use(cors());
app.use(bodyParser.json({
    limit: '50mb'
}));

app.use(bodyParser.urlencoded({
    limit: '50mb',
    parameterLimit: 100000,
    extended: true
}));


// set secret variable
app.set('secret', '91B917CA36B65ABCE1F21CA3D90EB0778CAC270441D1FD723BB91D77AF0');

app.use(expressJWT({
    secret: '91B917CA36B65ABCE1F21CA3D90EB0778CAC270441D1FD723BB91D77AF0'
}).unless({
    path: ['/register', '/login']
}));

app.use(bearerToken());

app.enable('trust proxy')
logger.level = 'debug';

app.use((req, res, next) => {

    logger.debug('New req for %s', req.originalUrl);
    // const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
    logger.info('IP : ' + req.ip);
    logger.info('Location : City    ' + lookup(req.ip).city);
    if (req.originalUrl.indexOf('/login') >= 0 || req.originalUrl.indexOf('/register') >= 0) {
        return next();
    }
    var token = req.token;
    jwt.verify(token, app.get('secret'), async (err, decoded) => {
        if (err) {
            logger.error(`Error ================:${err}`)
            res.send({
                success: false,
                message: 'Failed to authenticate token. Make sure to include the ' +
                    'token returned from /users call in the authorization header ' +
                    ' as a Bearer token'
            });
            return;
        } else {
            req.id = decoded.id;
            req.appointment = decoded.appointment;
            logger.info(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.id, (decoded.id[0] == 'P') ? 'Patient' : 'Doctor'));
            await query.getAsset(req.id, async function (result) {
                if (result.data == null) {
                    res.send({
                        data: null,
                        statusCode: '401',
                        status: 'error',
                        message: 'Invalid Token'
                    });
                } else {
                    return next();
                }
            })
        }
    });
});

var server = http.createServer(app).listen(port, function () { logger.debug(`Server started on ${port}`) });
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************', host, port);
server.timeout = 240000;

function getErrorMessage(field) {
    var response = {
        success: false,
        message: field + ' field is missing or Invalid in the request'
    };
    return response;
}




// Login and get jwt
app.post('/login', async function (req, res) {
    await query.login(req.body, async function (result) {

        if (result.statusCode == 200) {

            var token = jwt.sign({
                exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
                id: result.data.uidNo
            }, app.get('secret'));

            bcrypt.compare(req.body.password, result.data.password, async function (err, data) {

                if (data) {
                    res.json({
                        statusCode: 200,
                        token: token,
                        status: 'success',
                        uidNo: result.data.uidNo,
                        message: 'Logged In',
                        data: result.data
                    });
                } else {
                    res.json({
                        statusCode: 401,
                        token: "",
                        status: 'error',
                        data: {},
                        message: 'Invalid Credentials'
                    });

                }
            })
        }

        else {
            res.json({
                statusCode: 401,
                token: "",
                status: 'error',
                data: {},
                message: 'Invalid UserId / Password'
            });

        }
    })

});

app.post('/register', async function (req, res) {
    try {
        logger.debug('==================== Register ==================');

        const check = await database.database(req, 'checkUser');
        if (check.status) {
            await bcrypt.hash(req.body.password, saltRounds, async function (err, hash) {
                req.body.password = hash
                try {
                    var result = await invoke.invokeTransaction("registerUser", req.body, 'admin', 'Org1');
                    if (result.statusCode == 200) {
                        let response = await helper.getRegisteredUser(result.data.uidNo, 'Org1', 'User');
                        logger.info('-- returned from registering the username %s for organization %s', result.data.uidNo, 'Org1');
                        res.send(result);
                    }
                }
                catch (err) {
                    console.log(err)
                }
            });
        }
        else {
            res.send({
                statusCode: 401,
                status: 'error',
                data: {},
                message: check.message
            });
        }
    } catch (error) {
        const response_payload = {
            status: 'error',
            statuscode: 401,
            message: error.name,
            data: {}
        }
        res.send(response_payload)
    }
});
