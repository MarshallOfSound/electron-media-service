const os = require('os');
const semver = require('semver');

module.exports = require('./NullService');

switch (process.platform) {
  case 'darwin': {
    if (semver.satisfies(os.release(), '>=16.1.0')) {
      module.exports = require('./darwin');
    }
    break;
  }
  default: {
    break;
  }
}
