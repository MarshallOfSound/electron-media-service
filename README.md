Electron Media Service
---------------------------

[![Build Status](https://travis-ci.org/MarshallOfSound/electron-media-service.svg?branch=master)](https://travis-ci.org/MarshallOfSound/electron-media-service)
[![npm version](https://badge.fury.io/js/electron-media-service.svg)](https://www.npmjs.com/package/electron-media-service)
[![npm](https://img.shields.io/npm/dt/electron-media-service.svg?maxAge=2592000)](https://www.npmjs.com/package/electron-media-service)
[![license](https://img.shields.io/github/license/MarshallOfSound/electron-media-service.svg?maxAge=2592000)](https://github.com/GPMDP/electron-devtools-installer/blob/master/LICENSE)
![status](https://img.shields.io/badge/Status-%20Ready%20for%20Awesome-red.svg)

This is an easy way to get OS level media integration cross-platform in Electron, it hooks
into the following system API's.

| Platform | API | Requirements |
|----------|-----|--------------|
| `darwin` | [`MPRemoteCommandCenter`](https://developer.apple.com/reference/mediaplayer/mpremotecommandcenter?language=objc) and [`MPNowPlayingInfoCenter`](https://developer.apple.com/reference/mediaplayer/mpnowplayinginfocenter?language=objc) | macOS 10.12.1+ |
| `win32` *Coming Soon* | [`MediaTransportControls`](https://msdn.microsoft.com/en-us/library/windows/desktop/dn892355(v=vs.85).aspx) | Windows 10+ |
| `linux` *Coming Soon* | [`DBus`](https://dbus.freedesktop.org/doc/dbus-specification.html) | Well... DBus :D |

All you have to do to get all this awesome for you is

```js
import MediaService from 'electron-media-service';

const myService = new MediaService();

myService.startService();
myService.on('play', () => playSomething());
myService.on('pause', () => pauseSomething());
myService.setMetaData({
  title: 'Never Gonna Give You Up',
  // Other track meta data here
});
```

## What does it look like?

### macOS

![macOS](macOS.png)

## Methods

### `myService.startService()`

Starts the media service my registering the application with the system, no other methods
or events will work until this method is called.  It's a good idea to give users an option
to not start the service as it can be annoying for some users especially on Windows 10.

### `myService.stopService()`

Attempts to unregister the service from the system, sometimes a full relaunch is required
to unregister an application but this method tries it's hardest.

### `myService.isStarted()`

Returns `Boolean`, whether the service is started yet or not.  If you forget whether you
started it or not you can always call this method to check.

### `myService.setMetaData(meta)`

* `meta` Object - The current tracks MetaData
  * `title` String - The title of the track
  * `artist` String - The name of the artist
  * `album` String - The name of the album
  * `albumArt` String - HTTP url to an image for the album art
  * `state` String - One of `playing`, `paused` or `stopped`
  * `id` Number - A unique ID for this track, can be randomly generated as it doesn't really affect anything
  * `currentTime` Number - Progress through the track in milliseconds
  * `duration` Number - Total length of the track in milliseconds

## Events

### `myService.on('play')`

Fired when the user or the system requests the track to start playing

### `myService.on('pause')`

Fired when the user or the system requests the track to pause

### `myService.on('playPause')`

Fired when the user or the system requests the track to toggle between playing and paused

### `myService.on('next')`

Fired when the user or the system requests the player to skip to the next track

### `myService.on('previous')`

Fired when the user or the system requests the player to skip back to the previous track

### `myService.on('seek')`

Fired when the user or the system requests the player to seek through the track to the given time.

The target time will be given in milliseconds as the first argument to the event like so.

```js
myService.on('seek', (to) => {
  console.log(`We should seek to ${to}ms`)
})
```

## What happens on unsupported platforms?

We automatically give you a noop `MediaService` class, all methods do nothing and
no events are ever fired.  This allows you to not worry about supported platforms
and just write code.  Call whatever methods you want and nothing will break.

License
-------

The MIT License (MIT)

Copyright (c) 2017 Samuel Attard

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
