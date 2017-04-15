#include "module.h"

class DarwinMediaService : public Nan::ObjectWrap
{
private:
  std::string queryString;
public:

  static NAN_METHOD(New);
  static NAN_METHOD(StartService);
  static NAN_METHOD(StopService);
  static NAN_METHOD(SetMetaData);
  static NAN_METHOD(Hook);

  static void Emit(std::string eventName);
  static void EmitWithInt(std::string eventName, int details);
};

@interface NativeMediaController : NSObject {
}
- (void)associateService:(DarwinMediaService*)service;
@end