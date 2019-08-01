#include "module.h"
#include "napi.h"
#include "uv.h"
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

Napi::FunctionReference DarwinMediaService::constructor;

Napi::Object DarwinMediaService::Init(Napi::Env env, Napi::Object exports) {
  Napi::HandleScope scope(env);

  Napi::Function func = DefineClass(env, "DarwinMediaService", {
    InstanceMethod("hook", &DarwinMediaService::Hook),
    InstanceMethod("startService", &DarwinMediaService::StartService),
    InstanceMethod("stopService", &DarwinMediaService::StopService),
    InstanceMethod("setMetaData", &DarwinMediaService::SetMetaData)
  });

  constructor = Napi::Persistent(func);
  constructor.SuppressDestruct();

  exports.Set("DarwinMediaService", func);
  return exports;
}

DarwinMediaService::DarwinMediaService(const Napi::CallbackInfo& info) : Napi::ObjectWrap<DarwinMediaService>(info)  {

}

// static Persistent<Function> persistentCallback;
static Napi::FunctionReference persistentCallback;
void DarwinMediaService::Hook(const Napi::CallbackInfo& info) {
  persistentCallback = Napi::Persistent(info[0].As<Napi::Function>());
  // persistentCallback.SuppressDestruct();
}

void DarwinMediaService::Emit(std::string eventName) {
  EmitWithInt(eventName, 0);
}

void DarwinMediaService::EmitWithInt(std::string eventName, int details) {
  if (persistentCallback != nullptr) {
    persistentCallback.Call({
      Napi::String::New(persistentCallback.Env(), eventName.c_str()),
      Napi::Number::New(persistentCallback.Env(), details)
    });
  }


}

void DarwinMediaService::StartService(const Napi::CallbackInfo& info) {
  NativeMediaController* controller = [[NativeMediaController alloc] init];
  [controller associateService:this];

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

void DarwinMediaService::StopService(const Napi::CallbackInfo& info) {  
  MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
  [remoteCommandCenter playCommand].enabled = false;
  [remoteCommandCenter pauseCommand].enabled = false;
  [remoteCommandCenter togglePlayPauseCommand].enabled = false;
  [remoteCommandCenter changePlaybackPositionCommand].enabled = false;
}

void DarwinMediaService::SetMetaData(const Napi::CallbackInfo& info) {
  std::string songTitle = info[0].As<Napi::String>().Utf8Value().c_str();
  std::string songArtist = info[1].As<Napi::String>().Utf8Value().c_str();
  std::string songAlbum = info[2].As<Napi::String>().Utf8Value().c_str();
  std::string songState = info[3].As<Napi::String>().Utf8Value().c_str();

  unsigned int songID = info[4].As<Napi::Number>();
  unsigned int currentTime = info[5].As<Napi::Number>();
  unsigned int duration = info[6].As<Napi::Number>();

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
