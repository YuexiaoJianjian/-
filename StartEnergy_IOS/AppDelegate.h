//
//  AppDelegate.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 15/12/30.
//  Copyright © 2015年 维斯顿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "UpdateViewsFunc.h"
#import "GeTuiSdk.h"




#define kGtAppId           @"HBtPXbVQqm7xdMsTUOBs49"
#define kGtAppKey          @"iUqEvcppsq8Wppd17seBA1"
#define kGtAppSecret       @"WZGWnqntzz6nRoexVwzVz9"

#define NOTIFICATION_REFLASH_MESSAGE @"MSGREFLASH_ZUOMUNIAO"
#define NOTIFICATION_POST_CID @"POSTCID_ZUOMUNIAO"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *APPCID;


/**
 获取个推的AppId、AppKey、AppSecret
 Demo演示时代码，正式集成时可以简化该模块
 */
void UncaughtExceptionHandler(NSException *exception);
+ (NSString *)getGtAppId;
+ (NSString *)getGtAppKey;
+ (NSString *)getGtAppSecret;
@property (assign, nonatomic) int lastPayloadIndex;
- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret;

@end

