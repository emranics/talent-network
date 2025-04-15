'use strict';

const shim = require('fabric-shim');
const TalentChaincode = require('./lib/talentChaincode');

shim.start(new TalentChaincode());
