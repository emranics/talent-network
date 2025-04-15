const FabricCAServices = require('fabric-ca-client');
const {Wallets} = require('fabric-network');
const path = require('path');
const fs = require('fs');

const orgNameMap = {
    talentorg: "TalentOrg",
    universityorg: "UniversityOrg",
    companyorg: "CompanyOrg"
};

async function registerUser(org, userId, affiliation = '') {
    const ccpPath = path.resolve(__dirname, 'config', `connection-${org}.json`);
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

    const caInfo = ccp.certificateAuthorities[`ca.${org}`];
    const ca = new FabricCAServices(caInfo.url);
    const walletPath = path.join(__dirname, 'wallet', org);
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const userExists = await wallet.get(userId);
    if (userExists) {
        console.log(`User ${userId} already exists in ${org}`);
        return;
    }

    const adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
        throw new Error(`Admin identity for ${org} not found`);
    }

    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');

    await ca.register({
        affiliation,
        enrollmentID: userId,
        enrollmentSecret: userId,
        role: 'client'
    }, adminUser);

    const enrollment = await ca.enroll({
        enrollmentID: userId,
        enrollmentSecret: userId
    });

    const identity = {
        credentials: {
            certificate: enrollment.certificate,
            privateKey: enrollment.key.toBytes()
        },
        mspId: ccp.organizations[orgNameMap[org]].mspid,
        type: 'X.509'
    };

    await wallet.put(userId, identity);
    console.log(`✅ Registered and enrolled user ${userId} in ${org}`);
}

module.exports = registerUser;
