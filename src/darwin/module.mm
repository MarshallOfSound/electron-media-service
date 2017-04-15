#include "module.h"

NAN_MODULE_INIT(InitAddon) {
  v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(DarwinMediaService::New);

  tpl->SetClassName(Nan::New("DarwinMediaService").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  Nan::SetPrototypeMethod(tpl, "startService", DarwinMediaService::StartService);
  Nan::SetPrototypeMethod(tpl, "stopService", DarwinMediaService::StopService);
  Nan::SetPrototypeMethod(tpl, "setMetaData", DarwinMediaService::SetMetaData);
  Nan::SetPrototypeMethod(tpl, "hook", DarwinMediaService::Hook);

  Nan::Set(target,
      Nan::New("DarwinMediaService").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());
}

NODE_MODULE(addon, InitAddon)