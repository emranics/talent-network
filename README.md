# TalentChain: Blockchain-Based Talent Credential Verification System

TalentChain is a permissioned blockchain platform built with **Hyperledger Fabric v2.5**, enabling trusted verification and sharing of talent credentials. It allows individuals to register personal and professional records, receive credentials from universities, and share their verified profiles securely with employers.

---

## 🏗️ Architecture Overview

- **Blockchain Network:** Multi-org Fabric network with a shared channel `talentchannel`
- **Chaincode:** Written in Node.js; manages registration, credentialing, verification, and sharing
- **REST API:** Node.js-based server using Fabric SDK to interact with the ledger

---

## 📦 Features

### 🔐 Smart Contract (Chaincode)
- `RegisterTalent(talentID, name, email)`
- `AddCredential(talentID, credentialID, type, issuer, description)`
- `VerifyCredential(talentID, credentialID, issuer)`
- `RevokeCredential(talentID, credentialID, issuer)`
- `ShareProfile(talentID, orgID)`
- `ViewSharedProfile(talentID, orgID)`
- `ListAllTalents()`
- `GetTalentInfo(talentID)`
- `GetCredentialByID(talentID, credentialID)`

### 🌐 REST API Endpoints
Accessible via HTTP to allow frontend integration or external systems to interact with the blockchain.

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/emranics/talent-network
cd talent-network
```

### 2. Start the Network
```bash
make prod
```

### 3. Start the REST API
```bash
cd talent-api
npm install
npm start
```
