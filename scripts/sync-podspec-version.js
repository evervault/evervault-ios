const fs = require('fs');

const version = require('../package.json').version;
const podspecPath = 'Evervault.podspec';
const content = fs.readFileSync(podspecPath, 'utf8');
const updated = content.replace(/(s\.version\s*=\s*')[^']*'/, `$1${version}'`);
fs.writeFileSync(podspecPath, updated);
console.log(`Synced Evervault.podspec to ${version}`);
