const { DarwinMediaService } = require('bindings')('electron_media_service.node');
const { EventEmitter } = require('events');

class MediaService extends EventEmitter {
  constructor() {
    super();
    this.service = new DarwinMediaService();
    this._started = false;
  }

  _requireStart() {
    if (!this.isStarted()) {
      throw new Error('This method requires the media service be started before calling');
    }
  }

  startService() {
    this._started = true;
    this.service.startService();
    this.service.hook((eventName, arg) => {
      if (arg === -1) {
        this.emit(eventName);
      } else {
        this.emit(eventName, arg * 1000);
      }
    });
  }

  stopService() {
    this._requireStart();
    this._started = false;
    this.service.stopService();
  }

  isStarted() {
    return this._started;
  }

  setMetaData({
    currentTime,
    duration,
    title,
    artist,
    album,
    id,
    state,
  }) {
    this._requireStart();
    this.service.setMetaData(
      title,
      artist,
      album,
      state,
      id,
      currentTime / 1000,
      duration / 1000,
    );
  }
}

MediaService.STATES = {
  PLAYING: 'playing',
  PAUSED: 'paused',
  STOPPED: 'stopped',
};

module.exports = MediaService;
