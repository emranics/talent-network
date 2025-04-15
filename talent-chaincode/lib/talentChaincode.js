'use strict';

const shim = require('fabric-shim');

class TalentChaincode {
    async Init(stub) {
        console.info('✅ Talent chaincode instantiated.');
        return shim.success();
    }

    async Invoke(stub) {
        const {fcn, params} = stub.getFunctionAndParameters();
        const method = this[fcn];

        if (!method) {
            return shim.error(`❌ Unknown function ${fcn}`);
        }

        try {
            const result = await method.call(this, stub, ...params);
            return shim.success(result);
        } catch (err) {
            return shim.error(Buffer.from(err.message));
        }
    }

    // --- TALENT ---

    async RegisterTalent(stub, id, name, email) {
        if (!id || !name || !email) throw new Error('Missing talent ID, name or email.');

        const exists = await stub.getState(id);
        if (exists && exists.length > 0) throw new Error(`Talent ${id} already exists.`);

        const talent = {
            id,
            name,
            email,
            credentials: [],
            sharedWith: []
        };

        await stub.putState(id, Buffer.from(JSON.stringify(talent)));
        return Buffer.from(JSON.stringify(talent));
    }

    async GetTalentInfo(stub, id) {
        const data = await stub.getState(id);
        if (!data || data.length === 0) throw new Error(`Talent ${id} not found.`);
        return data;
    }

    async ShareProfile(stub, id, viewerID) {
        const data = await stub.getState(id);
        if (!data || data.length === 0) throw new Error(`Talent ${id} not found.`);
        const talent = JSON.parse(data);

        if (!talent.sharedWith.includes(viewerID)) {
            talent.sharedWith.push(viewerID);
            await stub.putState(id, Buffer.from(JSON.stringify(talent)));
        }

        return Buffer.from(`Profile shared with ${viewerID}`);
    }

    async ListAllTalents(stub) {
        const iterator = await stub.getStateByRange('', '');
        const results = [];

        while (true) {
            const res = await iterator.next();

            if (res.value && res.value.value.toString()) {
                try {
                    const record = JSON.parse(res.value.value.toString('utf8'));
                    if (record && record.id && record.name && record.email) {
                        results.push(record);
                    }
                } catch (err) {
                    console.error(`Error parsing record: ${err}`);
                }
            }

            if (res.done) {
                await iterator.close();
                break;
            }
        }

        return Buffer.from(JSON.stringify(results));
    }

    // --- CREDENTIALS ---

    async AddCredential(stub, talentID, credentialID, type, issuer, details) {
        const data = await stub.getState(talentID);
        if (!data || data.length === 0) throw new Error(`Talent ${talentID} not found.`);

        const talent = JSON.parse(data);

        const txTimestamp = stub.getTxTimestamp();
        const timestamp = new Date(txTimestamp.seconds * 1000).toISOString();

        const credential = {
            id: credentialID,
            type,
            issuer,
            details,
            verified: false,
            revoked: false,
            timestamp
        };
        talent.credentials.push(credential);

        await stub.putState(talentID, Buffer.from(JSON.stringify(talent)));
        return Buffer.from(JSON.stringify(credential));
    }

    async VerifyCredential(stub, talentID, credentialID, issuer) {
        const data = await stub.getState(talentID);
        if (!data || data.length === 0) throw new Error(`Talent ${talentID} not found.`);
        const talent = JSON.parse(data);

        const cred = talent.credentials.find(c => c.id === credentialID);
        if (!cred) throw new Error(`Credential ${credentialID} not found.`);
        if (cred.issuer !== issuer) throw new Error('Only the issuer can verify this credential.');

        cred.verified = true;
        await stub.putState(talentID, Buffer.from(JSON.stringify(talent)));
        return Buffer.from(JSON.stringify(cred));
    }

    async RevokeCredential(stub, talentID, credentialID, issuer) {
        const data = await stub.getState(talentID);
        if (!data || data.length === 0) throw new Error(`Talent ${talentID} not found.`);
        const talent = JSON.parse(data);

        const cred = talent.credentials.find(c => c.id === credentialID);
        if (!cred) throw new Error(`Credential ${credentialID} not found.`);
        if (cred.issuer !== issuer) throw new Error('Only the issuer can revoke this credential.');

        cred.revoked = true;
        await stub.putState(talentID, Buffer.from(JSON.stringify(talent)));
        return Buffer.from(`Credential ${credentialID} revoked.`);
    }

    async GetCredentialByID(stub, talentID, credentialID) {
        const data = await stub.getState(talentID);
        if (!data || data.length === 0) throw new Error(`Talent ${talentID} not found.`);
        const talent = JSON.parse(data);

        const cred = talent.credentials.find(c => c.id === credentialID);
        if (!cred) throw new Error(`Credential ${credentialID} not found.`);
        return Buffer.from(JSON.stringify(cred));
    }

    // --- VERIFIER ---

    async ViewSharedProfile(stub, talentID, viewerID) {
        const data = await stub.getState(talentID);
        if (!data || data.length === 0) throw new Error(`Talent ${talentID} not found.`);
        const talent = JSON.parse(data);

        if (!talent.sharedWith.includes(viewerID)) {
            throw new Error(`Viewer ${viewerID} is not authorized to view this profile.`);
        }

        return Buffer.from(JSON.stringify(talent));
    }
}

module.exports = TalentChaincode;
