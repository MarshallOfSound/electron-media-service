const { EventEmitter } = require('events');

class NullService extends EventEmitter {
  startService() {}
  stopService() {}
  isStarted() { return false; }
  setMetaData() {}
}

module.exports = NullService;
