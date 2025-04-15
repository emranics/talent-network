const FabricCAServices = require('fabric-ca-client');
const {Wallets} = require('fabric-network');
const path = require('path');
const fs = require('fs');

const orgNameMap = {
    talentorg: "TalentOrg",
    universityorg: "UniversityOrg",
    companyorg: "CompanyOrg"
};

async function enrollAdmin(org) {
    const ccpPath = path.resolve(__dirname, 'config', `connection-${org}.json`);
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

    const caInfo = ccp.certificateAuthorities[`ca.${org}`];
    const ca = new FabricCAServices(caInfo.url);
    const walletPath = path.join(__dirname, 'wallet', org);
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const adminIdentity = await wallet.get('admin');
    if (adminIdentity) {
        console.log(`Admin already enrolled for ${org}`);
        return;
    }

    const enrollment = await ca.enroll({enrollmentID: 'admin', enrollmentSecret: 'adminpw'});
    const identity = {
        credentials: {
            certificate: enrollment.certificate,
            privateKey: enrollment.key.toBytes()
        },
        mspId: ccp.organizations[orgNameMap[org]].mspid,
        type: 'X.509'
    };
    await wallet.put('admin', identity);
    console.log(`✅ Enrolled admin for ${org}`);
}

module.exports = enrollAdmin;
