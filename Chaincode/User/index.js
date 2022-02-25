'use strict';

const patient = require('./patient');
const common = require('./common');


module.exports.Patient = patient;
module.exports.Common = common;

module.exports.contracts = [patient, common];