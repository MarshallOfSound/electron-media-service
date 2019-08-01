#ifndef MYOBJECT_H
#define MYOBJECT_H

#include "module.h"

class DarwinMediaService : public Napi::ObjectWrap<DarwinMediaService> {
 public:
  static Napi::Object Init(Napi::Env env, Napi::Object exports);
  DarwinMediaService(const Napi::CallbackInfo& info);
  static void Emit(std::string eventName);
  static void EmitWithInt(std::string eventName, int details);

  void StartService(const Napi::CallbackInfo& info);
  void StopService(const Napi::CallbackInfo& info);
  void SetMetaData(const Napi::CallbackInfo& info);
  void Hook(const Napi::CallbackInfo& info);

 private:
  static Napi::FunctionReference constructor;
  std::string queryString_;

};

@interface NativeMediaController : NSObject {
}
- (void)associateService:(DarwinMediaService*)service;
@end

#endif