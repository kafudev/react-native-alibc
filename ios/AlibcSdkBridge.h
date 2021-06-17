//
//  AlibcSdkBridge.h
//  RNAlibcSdk
//
//  Created by et on 17/4/18.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#if __has_include(<React/RCTBridgeModule.h>)
//#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif
#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif



typedef void (^CompletionHandler)();

@interface AlibcSdkBridge : NSObject <RCTBridgeModule>

+ (instancetype)sharedInstance;
- (void)init: (NSString *)pid forceH5:(BOOL)forceH5 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)login: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)isLogin: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)getUser: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)logout: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)show: (NSDictionary *)param open:(NSString *)open resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)showInWebView: (UIWebView *)webView url:(NSString *)url param:(NSDictionary *)param;
@end


//@interface AlibcSdkBridge : NSObject
//
//@end
