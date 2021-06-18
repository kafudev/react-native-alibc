//
//  AlibcSdkBridge.m
//  RNAlibcSdk
//
//  Created by et on 2021/4/18.
//  Copyright © 2021年 Facebook. All rights reserved.
//

#import "AlibcSdkBridge.h"
#import <React/RCTLog.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/RCTImageLoader.h>
#import <AlibabaAuthEntrance/ALBBSDK.h>
#import <AlibabaAuthEntrance/ALBBCompatibleSession.h>
#import <AlibcTradeSDK/AlibcTradeSDK.h>
#import <AlibcTradeBiz/AlibcWebViewController.h>
#import <AlibcTradeSDK/AlibcTradePageFactory.h>
#import "UIKit/UIKit.h"


#define NOT_LOGIN (@"not login")

static NSString *const kOpenURLNotification = @"RCTOpenURLNotification";

@interface AlibcSdkBridge ()
@property (nonatomic, copy) RCTPromiseResolveBlock payOrderResolve;

@end

@implementation AlibcSdkBridge {
    AlibcTradeTaokeParams *taokeParams;
    AlibcTradeShowParams *showParams;
}

+ (instancetype) sharedInstance
{
    static AlibcSdkBridge *instance = nil;
    if (!instance) {
        instance = [[AlibcSdkBridge alloc] init];
    }
    return instance;
}
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(init:(NSString *)appkey pid:(NSString *)pid resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    // 配置全局的淘客参数
    //如果没有阿里妈妈的淘客账号,setTaokeParams函数需要调用
    taokeParams = [[AlibcTradeTaokeParams alloc] init];
    taokeParams.pid = pid;
    taokeParams.extParams = @{
      @"taobaoAppKey":appkey
    };
    [[AlibcTradeSDK sharedInstance] setTaokeParams:taokeParams];

    showParams = [[AlibcTradeShowParams alloc] init];
    showParams.openType = AlibcOpenTypeAuto;

    //设置全局的app标识，在电商模块里等同于isv_code
    //没有申请过isv_code的接入方,默认不需要调用该函数
    //[[AlibcTradeSDK sharedInstance] setISVCode:@"your_isv_code"];

    // 设置全局配置，是否强制使用h5
    // [[AlibcTradeSDK sharedInstance] setIsForceH5:YES];

    // 初始化AlibabaAuthSDK
    [[ALBBSDK sharedInstance] ALBBSDKInit];
    [[ALBBSDK sharedInstance] setAppkey:appkey];

    // 百川平台基础SDK初始化，加载并初始化各个业务能力插件
    // 开发阶段打开日志开关，方便排查错误信息
    // 默认调试模式打开日志,release关闭,可以不调用下面的函数
    [[AlibcTradeSDK sharedInstance] setDebugLogOpen:YES]; //开发阶段打开日志开关，方便排查错误信息
    [[AlibcTradeSDK sharedInstance] setIsvVersion:@"2.2.2"];
    [[AlibcTradeSDK sharedInstance] setIsvAppName:@"baichuanDemo"];
    [[AlibcTradeSDK sharedInstance] asyncInitWithSuccess:^{
        TLOG_INFO(@"百川SDK初始化成功");
        NSDictionary *ret = @{@"code": @1, @"msg": @"初始化成功"};
        resolve(ret);
    } failure:^(NSError *error) {
        TLOG_INFO(@"百川SDK初始化失败");
        NSDictionary *ret = @{@"code": @(error.code), @"msg":error.description};
        resolve(ret);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_METHOD(login: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  if(![[ALBBCompatibleSession sharedInstance] isLogin]) {
    [[ALBBSDK sharedInstance] setH5Only:NO];
    [[ALBBSDK sharedInstance] auth:[UIApplication sharedApplication].delegate.window.rootViewController successCallback:^{
        NSString *tip = [NSString stringWithFormat:@"登录的用户信息:%@",[[ALBBCompatibleSession sharedInstance] getUser]];
        NSLog(@"%@", tip);
        ALBBUser *s = [[ALBBCompatibleSession sharedInstance] getUser];
        NSDictionary *ret = @{@"code": @1, @"msg": @"登录成功", @"nick": s.nick, @"avatarUrl":s.avatarUrl, @"openId":s.openId, @"openSid":s.openSid, @"topAccessToken":s.topAccessToken, @"topAuthCode":s.topAuthCode,};
        resolve(ret);
    } failureCallback:^(NSError *error) {
        NSString *tip=[NSString stringWithFormat:@"登录失败:%@",@""];
        NSLog(@"%@", tip);
        NSDictionary *ret = @{@"code": @(error.code), @"msg":error.description};
        resolve(ret);
    }];
  } else {
      NSString *tip = [NSString stringWithFormat:@"登录的用户信息:%@",[[ALBBCompatibleSession sharedInstance] getUser]];
      NSLog(@"%@", tip);
      ALBBUser *s = [[ALBBCompatibleSession sharedInstance] getUser];
      NSDictionary *ret = @{@"code": @1, @"msg": @"登录成功", @"nick": s.nick, @"avatarUrl":s.avatarUrl, @"openId":s.openId, @"openSid":s.openSid, @"topAccessToken":s.topAccessToken, @"topAuthCode":s.topAuthCode,};
      resolve(ret);
  }
}

RCT_EXPORT_METHOD(isLogin: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    bool isLogin = [[ALBBCompatibleSession sharedInstance] isLogin];
    resolve([NSNumber numberWithBool: isLogin]);
}

RCT_EXPORT_METHOD(getUser: resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if([[ALBBCompatibleSession sharedInstance] isLogin]){
        ALBBUser *s = [[ALBBCompatibleSession sharedInstance] getUser];
        NSDictionary *ret = @{@"code": @1, @"msg": @"登录用户信息", @"nick": s.nick, @"avatarUrl":s.avatarUrl, @"openId":s.openId, @"openSid":s.openSid, @"topAccessToken":s.topAccessToken, @"topAuthCode":s.topAuthCode};
        resolve(ret);
    } else {
        NSDictionary *ret = @{@"code": @-1, @"msg": @"无登录用户信息"};
        resolve(ret);
    }
}

RCT_EXPORT_METHOD(logout: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[ALBBSDK sharedInstance] logout];
    NSDictionary *ret = @{@"code": @1, @"msg": @"退出成功"};
    resolve(ret);
}

RCT_EXPORT_METHOD(open: (NSDictionary *)param openType:(NSString *)openType clientType:(NSString *)clientType resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *type = param[@"type"];
    showParams.openType = AlibcNativeFailModeNone;
    if([openType isEqualToString:@"None"]){
        showParams.openType = AlibcNativeFailModeNone;
    } else if([openType isEqualToString:@"H5"]){
        showParams.openType = AlibcOpenTypeAuto;
    } else if([openType isEqualToString:@"Auto"]){
        showParams.openType = AlibcOpenTypeAuto;
    } else if([openType isEqualToString:@"Native"]){
        showParams.openType = AlibcOpenTypeNative;
    } else if([openType isEqualToString:@"DownloadPage"]){
        showParams.openType = AlibcNativeFailModeJumpDownloadPage;
    }
    NSString *bizCode = nil;
    id<AlibcTradePage> page;
    if ([type isEqualToString:@"url"]) {
        AlibcWebViewController* view = [[AlibcWebViewController alloc] init];
        NSInteger res  =  [[AlibcTradeSDK sharedInstance].tradeService
         openByUrl:(NSString *)param[@"url"]
         identity:@"trade"
         webView:view.webView
         parentController:view
         showParams:showParams
         taoKeParams:taokeParams
         trackParam:nil
         tradeProcessSuccessCallback:^(AlibcTradeResult * _Nullable result) {
            NSDictionary *ret = @{@"code": @1, @"msg":@"打开成功"};
            resolve(ret);
         } tradeProcessFailedCallback:^(NSError * _Nullable error) {
            NSDictionary *ret = @{@"code": @(error.code), @"msg":error.description};
            resolve(ret);
         }
        ];
        if (res == 1) {
            UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            [appRootVC presentViewController:view animated:YES completion:nil];
        }
        return;
    } else if ([type isEqualToString:@"detail"]) {
        bizCode = @"detail";
        page = [AlibcTradePageFactory itemDetailPage:(NSString *)param[@"payload"]];
    } else if ([type isEqualToString:@"shop"]) {
        bizCode = @"shop";
        page = [AlibcTradePageFactory shopPage:(NSString *)param[@"payload"]];
    } else if ([type isEqualToString:@"orders"]) {
        bizCode = @"orders";
        NSDictionary *payload = (NSDictionary *)param[@"payload"];
        page = [AlibcTradePageFactory myOrdersPage:[payload[@"orderType"] integerValue] isAllOrder:[payload[@"isAllOrder"] boolValue]];
    } else if ([type isEqualToString:@"addCard"]) {
        bizCode = @"addCard";
        page = [AlibcTradePageFactory addCartPage:(NSString *)param[@"payload"]];
    } else if ([type isEqualToString:@"mycard"]) {
        bizCode = @"cart";
        page = [AlibcTradePageFactory myCartsPage];
    } else {
        RCTLog(@"not implement");
        resolve(NO);
        return;
    }

    // 调用openByBizCode
    showParams.isNeedPush=NO;
    showParams.nativeFailMode=AlibcNativeFailModeJumpH5;
    showParams.linkKey=@"taobao";
    showParams.openType = AlibcOpenTypeAuto;
    showParams.isNeedCustomNativeFailMode = YES;
    AlibcWebViewController* view = [[AlibcWebViewController alloc] init];
    NSInteger res  =  [[AlibcTradeSDK sharedInstance].tradeService
     openByBizCode:bizCode
     page:page
     webView:view.webView
     parentController:view
     showParams:showParams// 跳转方式
     taoKeParams:taokeParams  //配置 阿里妈妈信息
     trackParam:nil // [self customParam]
     tradeProcessSuccessCallback:^(AlibcTradeResult * _Nullable result) {
        NSDictionary *ret = @{@"code": @1, @"msg":@"打开成功"};
        resolve(ret);
     } tradeProcessFailedCallback:^(NSError * _Nullable error) {
        NSDictionary *ret = @{@"code": @(error.code), @"msg":error.description};
        resolve(ret);
     }
    ];
    if (res == 1) {
        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [appRootVC presentViewController:view animated:YES completion:nil];
    }
}

- (NSString *)appScheme {
    NSArray *urlTypes = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"];
    for (NSDictionary *urlType in urlTypes) {
        NSString *urlName = urlType[@"CFBundleURLName"];
        if ([urlName hasPrefix:@"alipay"]) {
            NSArray *schemes = urlType[@"CFBundleURLSchemes"];
            return schemes.firstObject;
        }
    }
    return nil;
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    [URLContexts enumerateObjectsUsingBlock:^(UIOpenURLContext * _Nonnull obj,
                                              BOOL * _Nonnull stop) {
        if([[AlibcTradeSDK sharedInstance] application:nil
                                               openURL:obj.URL
                                               options:nil]){
            *stop = YES;
        }
    }];
}
@end
