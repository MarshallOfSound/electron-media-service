#include "module.h"

Napi::Object InitAddon(Napi::Env env, Napi::Object exports) {
    return DarwinMediaService::Init(env, exports);
}

NODE_API_MODULE(addon, InitAddon)