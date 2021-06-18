#import "Alibc.h"
#import "AlibcSdkBridge.h"

#import <React/RCTLog.h>

#define NOT_LOGIN (@"not login")

@implementation Alibc

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_REMAP_METHOD(multiply,
                 multiplyWithA:(nonnull NSNumber*)a withB:(nonnull NSNumber*)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
  NSNumber *result = @([a floatValue] * [b floatValue]);

  resolve(result);
}

RCT_EXPORT_METHOD(init: (NSString *)appkey  pid:(NSString *)pid resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[AlibcSdkBridge sharedInstance] init:appkey pid:pid resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(login: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[AlibcSdkBridge sharedInstance] login:resolve rejecter:reject];
}
RCT_EXPORT_METHOD(isLogin: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[AlibcSdkBridge sharedInstance] isLogin:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(getUser: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[AlibcSdkBridge sharedInstance] getUser:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(logout: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[AlibcSdkBridge sharedInstance] logout:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(show: (NSDictionary *)param open:(NSString *)open resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    [[AlibcSdkBridge sharedInstance] show:param open:open resolver:resolve rejecter:reject];
}

@end
