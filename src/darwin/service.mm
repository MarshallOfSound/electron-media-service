#include "module.h"
#include "nan.h"
#import <AppKit/AppKit.h>

@implementation NativeMediaController
  DarwinMediaService* _service;

- (void)associateService:(DarwinMediaService*)service {
  _service = service;
}

- (void)remotePlay { _service->Emit("play"); }
- (void)remotePause { _service->Emit("pause"); }
- (void)remoteTogglePlayPause { _service->Emit("playPause"); }
- (void)remoteNext { _service->Emit("next"); }
- (void)remotePrev { _service->Emit("previous"); }

- (void)remoteChangePlaybackPosition:(MPChangePlaybackPositionCommandEvent*)event {
  _service->EmitWithInt("seek", event.positionTime);
}

- (MPRemoteCommandHandlerStatus)move:(MPChangePlaybackPositionCommandEvent*)event {
  return MPRemoteCommandHandlerStatusSuccess;
}

@end

// static Persistent<Function> persistentCallback;
static Nan::Callback persistentCallback;
NAN_METHOD(DarwinMediaService::Hook) {
  Nan::ObjectWrap::Unwrap<DarwinMediaService>(info.This());

  v8::Local<v8::Function> function = v8::Local<v8::Function>::Cast(info[0]);
  persistentCallback.SetFunction(function);
}

void DarwinMediaService::Emit(std::string eventName) {
  EmitWithInt(eventName, 0);
}

void DarwinMediaService::EmitWithInt(std::string eventName, int details) {
  v8::Local<v8::Value> argv[2] = {
    Nan::New<v8::String>(eventName.c_str()).ToLocalChecked(),
    Nan::New<v8::Integer>(details)
  };

  Nan::AsyncResource resource("auryo:addon.callback");

  persistentCallback.Call(2, argv, &resource);
}

NAN_METHOD(DarwinMediaService::New) {
  DarwinMediaService *service = new DarwinMediaService();
  service->Wrap(info.This());
  info.GetReturnValue().Set(info.This());
}

NAN_METHOD(DarwinMediaService::StartService) {
  DarwinMediaService *self = Nan::ObjectWrap::Unwrap<DarwinMediaService>(info.This());

  NativeMediaController* controller = [[NativeMediaController alloc] init];
  [controller associateService:self];

  MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
  [remoteCommandCenter playCommand].enabled = true;
  [remoteCommandCenter pauseCommand].enabled = true;
  [remoteCommandCenter togglePlayPauseCommand].enabled = true;
  [remoteCommandCenter changePlaybackPositionCommand].enabled = true;
  [remoteCommandCenter nextTrackCommand].enabled = true;
  [remoteCommandCenter previousTrackCommand].enabled = true;

  [[remoteCommandCenter playCommand] addTarget:controller action:@selector(remotePlay)];
  [[remoteCommandCenter pauseCommand] addTarget:controller action:@selector(remotePause)];
  [[remoteCommandCenter togglePlayPauseCommand] addTarget:controller action:@selector(remoteTogglePlayPause)];
  [[remoteCommandCenter changePlaybackPositionCommand] addTarget:controller action:@selector(remoteChangePlaybackPosition:)];
  [[remoteCommandCenter nextTrackCommand] addTarget:controller action:@selector(remoteNext)];
  [[remoteCommandCenter previousTrackCommand] addTarget:controller action:@selector(remotePrev)];
}

NAN_METHOD(DarwinMediaService::StopService) {
  Nan::ObjectWrap::Unwrap<DarwinMediaService>(info.This());
  
  MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
  [remoteCommandCenter playCommand].enabled = false;
  [remoteCommandCenter pauseCommand].enabled = false;
  [remoteCommandCenter togglePlayPauseCommand].enabled = false;
  [remoteCommandCenter changePlaybackPositionCommand].enabled = false;
}

NAN_METHOD(DarwinMediaService::SetMetaData) {
  Nan::ObjectWrap::Unwrap<DarwinMediaService>(info.This());

  std::string songTitle = *Nan::Utf8String(info[0]);
  std::string songArtist = *Nan::Utf8String(info[1]);
  std::string songAlbum = *Nan::Utf8String(info[2]);
  std::string songState = *Nan::Utf8String(info[3]);

  unsigned int songID = Nan::To<int>(info[4]).ToChecked();
  unsigned int currentTime = Nan::To<int>(info[5]).ToChecked();
  unsigned int duration = Nan::To<int>(info[6]).ToChecked();

  NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
  [songInfo setObject:[NSString stringWithUTF8String:songTitle.c_str()] forKey:MPMediaItemPropertyTitle];
  [songInfo setObject:[NSString stringWithUTF8String:songArtist.c_str()] forKey:MPMediaItemPropertyArtist];
  [songInfo setObject:[NSString stringWithUTF8String:songAlbum.c_str()] forKey:MPMediaItemPropertyAlbumTitle];
  [songInfo setObject:[NSNumber numberWithFloat:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
  [songInfo setObject:[NSNumber numberWithFloat:duration] forKey:MPMediaItemPropertyPlaybackDuration];
  [songInfo setObject:[NSNumber numberWithFloat:songID] forKey:MPMediaItemPropertyPersistentID];

  if (songState == "playing") {
    [MPNowPlayingInfoCenter defaultCenter].playbackState = MPNowPlayingPlaybackStatePlaying;
  } else if (songState == "paused") {
    [MPNowPlayingInfoCenter defaultCenter].playbackState = MPNowPlayingPlaybackStatePaused;
  } else {
    [MPNowPlayingInfoCenter defaultCenter].playbackState = MPNowPlayingPlaybackStateStopped;
  }

  [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
}
