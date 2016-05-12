//
//  AppDelegate.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 15/12/30.
//  Copyright © 2015年 维斯顿. All rights reserved.
//

#import "AppDelegate.h"

#define NotifyActionKey "NotifyAction"

NSString *const NotificationCategoryIdent = @"ACTIONABLE";
NSString *const NotificationActionOneIdent = @"ACTION_ONE";
NSString *const NotificationActionTwoIdent = @"ACTION_TWO";

@interface AppDelegate ()
{
    UIViewController *vc;
    UpdateViewsFunc *update;
    
}
@end

@implementation AppDelegate
@synthesize lastPayloadIndex,APPCID;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self startSdkWith:[AppDelegate getGtAppId] appKey:[AppDelegate getGtAppKey] appSecret:[AppDelegate getGtAppSecret]];
//    [self registerRemoteNotification];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POST_CID object:nil userInfo:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [UIApplication sharedApplication].applicationIconBadgeNumber = [db getAlarmMsgCount];
}

#pragma mark - 用户通知(推送) _自定义方法

/** 注册远程通知 */
- (void)registerRemoteNotification {
    
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //IOS8 新的通知机制category注册
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"取消"];
        [action1 setIdentifier:NotificationActionOneIdent];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"回复"];
        [action2 setIdentifier:NotificationActionTwoIdent];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[ action1, action2 ]
                        forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                        UIUserNotificationTypeSound |
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"deviceToken:%@", token);
    
    // [3]:向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    [GeTuiSdk registerDeviceToken:@""];
}

#pragma mark - APP运行中接收到通知(推送)处理

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // [4-EXT]:处理APN
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    // [4-EXT]:处理APN
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 启动GeTuiSdk

/**
 获取个推的AppId、AppKey、AppSecret
 注：该代码写法仅适用演示Demo，正式集成可简化，请参考“集成Demo”
 */
+ (NSString *)getGtAppId {
    NSString *reValue = kGtAppId;
    return reValue;
}
+ (NSString *)getGtAppKey {
    NSString *reValue = kGtAppKey;
    return reValue;
}
+ (NSString *)getGtAppSecret {
    NSString *reValue = kGtAppSecret;
    return reValue;
}

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    
    // 添加额外代码，方便测试修改App配置
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"gtsdk" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (configs) {
        // SDK测试使用的appid
        NSString *appid = configs[@"com.getui.kGTAppId"];
        if (appid && [appid isKindOfClass:[NSString class]] && appid.length) {
            appID = appid;
        }
        
        NSString *appkey = configs[@"com.getui.kGTAppKey"];
        if (appkey && [appkey isKindOfClass:[NSString class]] && appkey.length) {
            appKey = appkey;
        }
        
        NSString *appsecret = configs[@"com.getui.kGTAppSecret"];
        if (appsecret && [appsecret isKindOfClass:[NSString class]] && appsecret.length) {
            appSecret = appsecret;
        }
    }
    
    //[1-1]:通过 AppId、 appKey 、appSecret 启动SDK
    //该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:appID appKey:appKey appSecret:appSecret delegate:self];
    [GeTuiSdk runBackgroundEnable:YES];
    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
}

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSDictionary *Cid = [NSDictionary dictionaryWithObjectsAndKeys:
                         clientId, @"CID",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POST_CID object:nil userInfo:Cid];
//    NSLog(@">>>[GeTuiSdk RegisterClient]:%@", clientId);
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }
    
    NSString *record = [NSString stringWithFormat:@"%@",payloadMsg];
    record = [record stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];

    NSDictionary *alarmNotice = [NSDictionary dictionaryWithObjectsAndKeys:record,@"msg", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFLASH_MESSAGE object:nil userInfo:alarmNotice];
    
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    if([GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:aMsgId] == NO){
        //NSLog(@"返回消息失败");
    }
        
    
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    //NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
    
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    //NSLog(@"个推SDK出现错误：%@",[error description]);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
}

//SDK设置推送模式回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        return;
    }
}

- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

@end
