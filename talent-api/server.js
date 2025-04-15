const express = require('express');
const enrollAdmin = require('./enrollAdmin');
const registerUser = require('./registerUser');
const app = express();
app.use(express.json());

const ORGS = ['talentorg', 'universityorg', 'companyorg'];

app.post('/enroll-admin', async (req, res) => {
    try {
        const {org} = req.body;
        if (!ORGS.includes(org)) return res.status(400).send('Invalid org');
        await enrollAdmin(org);
        res.send(`Admin enrolled for ${org}`);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.post('/register-user', async (req, res) => {
    try {
        const {org, userId, affiliation} = req.body;
        if (!ORGS.includes(org)) return res.status(400).send('Invalid org');
        await registerUser(org, userId, affiliation);
        res.send(`User ${userId} registered for ${org}`);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.listen(4000, () => console.log('🌐 API server running on http://localhost:4000'));
