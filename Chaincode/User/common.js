'use strict';
const {
    Contract
} = require('fabric-contract-api');
const ClientIdentity = require('fabric-shim').ClientIdentity;

class common extends Contract {

    async myAssetExists(ctx, id) {
        const buffer = await ctx.stub.getPrivateData('patient_priv', id);
        return (!!buffer && buffer.length > 0);
    }
    // to fetch unique id everytime
    async IDGenerator(ctx, prefix) {
        let min = 100000000;
        let max = 999999999;
        let checkid = true;
        while (checkid) {
            let id = Math.floor(Math.random() * (max - min + 1)) + min
            id = prefix + id

            if (this.myAssetExists(ctx, id)) {
                checkid = false;
                return id;
            }
        }
    }

    async postData(ctx, id, Buffer) {
        await ctx.stub.putState(id, Buffer);
        return 'Data added successful';
    }


    async registerUser(ctx, data) {

        data = JSON.parse(data);
        let id = ''

        let prefix = 'USER_';
        id = await this.IDGenerator(ctx, prefix);

        var record = {
            uidNo: id,
            active: true,
            role: 'User',
            name: data.name,
            password: data.password,
            phoneNumber: data.phoneNumber,
        };
        const temp = await this.postData(ctx, id, Buffer.from(JSON.stringify(record)));
        var res = {
            status: 'success',
            statusCode: 200,
            message: "User " + id + " successfully registered.",
            data: {
                uidNo: id,
                role: data.role
            }
        };
        return JSON.stringify(res);

    }

}

module.exports = common;


