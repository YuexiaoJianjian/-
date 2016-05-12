//
//  ViewController.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 15/12/30.
//  Copyright © 2015年 维斯顿. All rights reserved.

/*
 版本记录：
1.0 基于啄木鸟2.0修改 、 重构Map和QR 两个页面
 */


#import "ViewController.h"
#import "JSInvokingOC.h"
#import "APIKey.h"
#import "Sha_NSString.h"
#import "AppDelegate.h"
#import <Accelerate/Accelerate.h>
#import "GeTuiSdk.h"
#import "PostFunc.h"
#import "QRScanLabel.h"
#import "CustomAnnotationView.h"


//#define DEBUG 1
//define TEST  1
//#define FINAL 1
#ifdef DEBUG //测试
    #define SE_HOSTLOGIN @"http://192.168.1.116:8000/"
    #define SE_SERVICEPRE @"http://192.168.1.116:9000"
#endif

#ifdef FINAL //正式
    #define SE_HOSTADDR @"http://52zmn.com:8010/User/DoorList.htm"
    #define SE_HOSTLOGIN @"http://52zmn.com:8010/"
    #define SE_SERVICEPRE @"http://52zmn.com:83/StarEnergyService"
#endif


#define SE_ERR_PAGENAME @"Error"
#define SE_HEART_INTERVAL 10
#define SE_ERR_PAGETYPE @"htm"

@interface ViewController ()
{
    
    UpdateViewsFunc *update;
}
@end

@implementation ViewController

@synthesize qrScanView,aMapLocationManager,locationManager,CID;


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    update = [[UpdateViewsFunc alloc]init];
    // Do any additional setup after loading the view, typically from a nib
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect mainFrame = CGRectMake(0,20, width, height-20);
    mWebView = [[UIWebView alloc]initWithFrame:mainFrame];
    mWebView.delegate = self;
    mWebView.backgroundColor = [UIColor whiteColor];
    ud = [NSUserDefaults standardUserDefaults];
    CID =[ud objectForKey:@"CID"];
    [self.view addSubview:mWebView];

    debug = 2;
    autoLogin = NO;
    autoFlag = NO;
//    if([self internetStatus] != 0){
    NSString *path = @"file:///index.html";
    [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5]];
    context = [mWebView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSInvokingOC *object = [[JSInvokingOC alloc]init];
    [object setMHandle:self];
    context[@"NJO_SE"] = object;
    timerTimes = 0;
    //Gesture
    swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(moveBack)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [mWebView addGestureRecognizer:swipeGesture];
    
    //location init
    // 高德
    [AMapLocationServices sharedServices].apiKey = (NSString *)APIKey;
    aMapLocationManager = [[AMapLocationManager alloc]init];
    [aMapLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //apple
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 1000.0f;
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    myThread = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReflashBtnTip2:) name:NOTIFICATION_REFLASH_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoticePostCID:) name:NOTIFICATION_POST_CID object:nil];
    
    msg = [[AlarmMsgLabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width,30)];
    timerBund = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(setContextJs) userInfo:nil repeats:YES];
    [timerBund setFireDate:[NSDate distantFuture]];
    HUDManager = [[MBProgressHUDManager alloc]initWithView:self.view];
}



-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(timerTimes == 5){
        [timerBund setFireDate:[NSDate distantFuture]];
        timerTimes = 0;
    }
    context = [mWebView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSInvokingOC *object = [[JSInvokingOC alloc]init];
    [object setMHandle:self];
    context[@"NJO_SE"] = object;
    // 页面加载完成
    if(autoLogin == YES){
            [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:///User/DoorList.htm"] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5]];
           autoFlag = YES;
           autoLogin = NO;
    }
    autoFlag = YES;
    [HUDManager hide];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    NSLog(@"%@",error.description);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = [NSString stringWithFormat:@"%@",request.URL];
    NSString *temp = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSRange range = [temp rangeOfString:[update GetDocumentPath]];
    if(range.location != NSNotFound)
    {
        [timerBund setFireDate:[NSDate distantFuture]];
        timerTimes = 0;
        [timerBund setFireDate:[NSDate distantPast]];
        [HUDManager showMessage:@"正在加载" mode:MBProgressHUDModeIndeterminate duration:5.0f];
        return YES;
    }
    NSString *docPath = [NSString stringWithFormat:@"%@/",[update GetDocumentPath]];
    url = [url stringByReplacingOccurrencesOfString:@"file:///" withString: docPath];
    [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5]];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}


/********************************************************************************************************************************/


-(void)setContextJs
{
    context = [mWebView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSInvokingOC *object = [[JSInvokingOC alloc]init];
    [object setMHandle:self];
    context[@"NJO_SE"] = object;
    timerTimes ++;
    if(timerTimes == 5){
        timerTimes =0;
        [timerBund setFireDate:[NSDate distantFuture]];
    }

}


#pragma mark - cid注册成功后消息通知
-(void)NoticePostCID:(NSNotification *)text
{
    //    NSDictionary *dic = text.userInfo;
    //    NSDate *startTime = [NSDate date];
    //    if(dic != nil)
    //    {
    //        [self setCID:dic[@"CID"]];
    //    }else
    //    {
    //        if(threadRun){
    //            if([self GetCIDState:startTime] < 1){
    //                if([self PostCID:startTime]< 1){
    //                    if([self PostCID:startTime]<1)
    //                    {
    //
    //                    }
    //                }
    //            }
    //        }
    //    }
}

#pragma mark - 个推消息通知
-(void)ReflashBtnTip2:(NSNotification *)text
{
    NSError *tError;
    NSDictionary *dic = text.userInfo;
    if(dic == nil)
    {
        return;
    }
    NSString *tmsg = dic[@"msg"];
    //解析 json
    NSData* jsonData = [tmsg dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *mAlarmMsg = [jsonData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode error:&tError];
    NSNumber *type = mAlarmMsg[@"MsgType"] ;
    
    if([type intValue] == 0){
        NSString *msgBody = mAlarmMsg[@"Msg"];
        NSData *bodyJson = [msgBody dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *mAlarmMsgBody = [bodyJson objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode error:&tError];
        if(mAlarmMsgBody == nil)
            return;
        else if([[mAlarmMsgBody objectForKey:@"EndTime"] isEqualToString:@""]){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
            NSString *msg2 = [NSString stringWithFormat:@"您有新的告警,请注意查收！"];
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:msg2]; //需要转换的文本
            AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CH"];
            utterance.voice = voiceType;
            //设置语速快慢
            utterance.rate *= 1.05f;
            //语音合成器会生成音频
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.view addSubview:msg];
            });
            [av speakUtterance:utterance];
            
            NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeMsg) userInfo:nil repeats:NO];
            NSString *tstr = [NSString stringWithFormat:@"%@",msgBody];
            // js 调用添加
            NSString *js =[NSString stringWithFormat:@"PJO_SE.CallAddRunAlarm(%@);",tstr];
            [context evaluateScript:js];
        }else{
            //js 调用移除
            NSString *js =[NSString stringWithFormat:@"PJO_SE.CallDeleteRunAlarm(%@);",[mAlarmMsgBody objectForKey:@"AlarmRecID"]];
            [context evaluateScript:js];
        }
    }else if([type intValue] == 1)
    {
        NSString *tLoginId = [ud objectForKey:@"loginID"];
        NSString *msgBody = mAlarmMsg[@"Msg"];
        NSData *bodyJson = [msgBody dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *mAlarmMsgBody = [bodyJson objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode error:&tError];
        if(![tLoginId isEqualToString:mAlarmMsgBody[@"LoginID"]])
            return;
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"警告" message:mAlarmMsgBody[@"Information"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alter show];
        [self logout];
        NSString *path = @"file:///index.html";
        [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5]];
    }
}

//移除新消息提示标签
-(void)removeMsg
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [msg removeFromSuperview];
    });
}


#pragma mark - 手势返回事件
-(void)moveBack
{
    mView= [self addBgView];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(updateTimer:) userInfo:nil repeats:NO];
    NSString *url = [NSString stringWithFormat:@"%@",[mWebView.request URL]];
    NSString *homePage = [NSString stringWithFormat:@"file://%@/User/DoorList.htm",[update GetDocumentPath]];
    if(![url isEqualToString:homePage])
    {
        NSString *js =[NSString stringWithFormat:@"PJO_SE.CallBackKeyDown();"];
        [context evaluateScript:js];
    }
    
}

-(void)updateTimer:(id)sender
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [mView removeFromSuperview];
    });
}

-(id)addBgView
{
    CGRect maskRect = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
    UIView *bg = [[UIView alloc] initWithFrame:maskRect];
    bg.backgroundColor = [UIColor colorWithRed:40/255.0 green:100/255.0 blue:160/255.0 alpha:0.7f];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, maskRect);
    [maskLayer setPath:path];
    CGPathRelease(path);
    bg.layer.mask = maskLayer;
    [self.view addSubview:bg];
    return bg;
}


#pragma mark - 心跳
//线程函数
-(void)HeartBeat
{
    NSDate *startTime = [NSDate date];
//    int cidStatus = [self GetCIDState:startTime];
//    if(cidStatus < 1 && ILoginId != nil ){
//        //开始的时候上报一次CID
//        int res1 = [self PostCID:startTime];
//        if(res1 < 1){
//            //重发
//            res1 = [self PostCID:startTime];
//        }
//    }
    while(threadRun)
    {
        if ((-[startTime timeIntervalSinceNow]) >= SE_HEART_INTERVAL) {
            startTime = [NSDate date];
//            int cidStatus = [self GetCIDState:startTime];
//            if(cidStatus < 1 && ILoginId != nil){
//                //开始的时候上报一次CID
//                int res1 = [self PostCID:startTime];
//                if(res1 < 1)
//                    res1 = [self PostCID:startTime];
//            }
            int res = [self HeartPost:startTime];
            if(res < 1)
                res = [self HeartPost:startTime];
            if(res < 1)
            {
                //重新登录
                res =[self Login:startTime];
                if(res < 1)
                    res = [self Login:startTime];
            }
        }
        [NSThread sleepForTimeInterval:0.5f];
    }
}

#pragma mark -获取CID状态
-(int)GetCIDState:(NSDate *)ARecordTime
{
    NSString *URLString = [NSString stringWithFormat:@"%@/GetCIDStatus",SE_SERVICEPRE];
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *ILoginId = [ud objectForKey:@"loginID"];
    NSTimeInterval time = [ARecordTime timeIntervalSince1970];
    long long int date = (long long int)time*1000;
    NSString * ITonce = [NSString stringWithFormat:@"%lld",date];
    NSString *IStr = [[NSString alloc] initWithFormat:@"%@%@%@",ILoginId,ITonce,@"WSDstarenergy@201510"];
    NSString * ICiphrt = [[IStr sha1] uppercaseString];
    NSDictionary *dc = [NSDictionary dictionaryWithObjectsAndKeys:
                        ILoginId,@"loginId",
                        ITonce,@"tonce",
                        ICiphrt,@"ciphertext",
                        CID,@"cId",nil];
    return [PostFunc postDataCid:dc Url:URL];
}


#pragma mark -上报 CID 个推唯一编码
-(int)PostCID:(NSDate*)ARecordTime
{
    NSString *URLString = [NSString stringWithFormat:@"%@/ReportCID",SE_SERVICEPRE];
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *ILoginId = [ud objectForKey:@"loginID"];
    NSTimeInterval time = [ARecordTime timeIntervalSince1970];
    long long int date = (long long int)time*1000;
    NSString * ITonce = [NSString stringWithFormat:@"%lld",date];
    NSString *IStr = [[NSString alloc] initWithFormat:@"%@%@%@",ILoginId,ITonce,@"WSDstarenergy@201510"];
    NSString * ICiphrt = [[IStr sha1] uppercaseString];
    NSDictionary *dc = [NSDictionary dictionaryWithObjectsAndKeys:
                        ILoginId,@"loginId",
                        ITonce,@"tonce",
                        ICiphrt,@"ciphertext",
                        CID,@"cId",nil];
   
    return [PostFunc postData:dc Url:URL];
}

#pragma mark - 心跳post方法
-(int)HeartPost:(NSDate*)ARecordTime
{
    NSString *random = [ud objectForKey:@"random"];
    NSString *urlStr=[NSString stringWithFormat:@"%@/PhoneRegisterService/HeartBeat?random=%@",SE_SERVICEPRE,random];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //    2.创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    return [PostFunc GetData:request];

}

#pragma mark - 登录post
-(int)Login:(NSDate*)ARecordTime
{
    NSString *ImobieTel = [ud objectForKey:@"username"];
    NSString *Ipassword = [ud objectForKey:@"password"];
    NSString *IVersion = [ud objectForKey:@"version"];
    NSString *Irandom = [ud objectForKey:@"random"];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/PhoneRegisterService/Login?userName=%@&password=%@&random=%@&Version=%@",SE_SERVICEPRE,ImobieTel,Ipassword,IVersion,Irandom];
    NSURL *url=[NSURL URLWithString:urlStr];
    //    2.创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    return [PostFunc GetData:request];
    
}
#pragma mark -打开线程 关闭线程
//打开线程
-(void)startThread
{
    threadRun = YES;
    if(myThread == nil){
        myThread = [[NSThread alloc]initWithTarget:self selector:@selector(HeartBeat) object:nil];
    }
    if(![myThread isExecuting])
        [myThread start];
}
//关闭线程
-(void)exitThread
{
    threadRun = NO;
    if([myThread isExecuting])
    {
        [myThread cancel];
        myThread = nil;
    }
}

#pragma mark - 打开二维码扫描界面
-(void)startQRScan
{
    mCustomQRView = [[CustomQRScanView alloc]initWithFrame:self.view.frame];
    [mCustomQRView setDelegate:self];
    [self.view addSubview:mCustomQRView];
}

#pragma mark - 获取位置信息
-(void)getLocInfo
{
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *currlocation  = [locations lastObject];
    NSString *Lat= [NSString stringWithFormat:@"%3.5f",currlocation.coordinate.latitude];
    NSString *Lng= [NSString stringWithFormat:@"%3.5f",currlocation.coordinate.longitude];
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currlocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error != nil)
        {
            [locationManager stopUpdatingLocation];
            //苹果如果获取失败，使用高德
            [aMapLocationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                if(regeocode == nil){
                    //失败 返回到js消息
                    NSString *str = [NSString stringWithFormat:@"{\"ret\":0,\"longitude\":\"\",\"latitude\":\"\",\"address\":\"\"}"];
                    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallLocation(%@);",str];
                    [context evaluateScript:js];
                }
                else
                {
                    //成功 返回到js消息
                    NSString *str = [NSString stringWithFormat:@"{\"ret\":1,\"longitude\":\"%@\",\"latitude\":\"%@\",\"address\":\"%@\"}",Lng,Lat,regeocode.formattedAddress];
                    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallLocation(%@);",str];
                    [context evaluateScript:js];
                }
            }];
            
        }else{
            [locationManager stopUpdatingLocation];
            for (CLPlacemark * placemark in placemarks) {
                NSString *provin = [placemark administrativeArea];//省
                NSString *city  =[placemark locality]; // 市
                NSString *street =[placemark thoroughfare];//街道
                NSString *subLocality =[placemark subLocality];//区
                NSString *subThoroughfare = [placemark subThoroughfare];//门号
                NSString *loc = [NSString stringWithFormat:@"%@%@%@%@%@",provin,city,subLocality,street,subThoroughfare];
                NSString *str = [NSString stringWithFormat:@"{\"ret\":1,\"longitude\":\"%@\",\"latitude\":\"%@\",\"address\":\"%@\"}",Lng,Lat,loc];
                NSString *js =[NSString stringWithFormat:@"PJO_SE.CallLocation(%@);",str];
                [context evaluateScript:js];
            }
        }
    }];
}

#pragma mark - 获取登陆信息
-(NSString *)getLoginData
{
    NSString *str;
    NSString *loginID = [ud objectForKey:@"loginID"];
    if(loginID == nil )
        str= [NSString stringWithFormat:@"{\"ret\":0,\"value\":\"%@\"}",@""];
    else
        str= [NSString stringWithFormat:@"{\"ret\":1,\"value\":\"%@\"}",loginID];
    return str;
   
}

#pragma mark - 设置登陆数据
-(void)setLoginData:(NSString *)name Password:(NSString *)password loginId:(NSString *)loginID
{
    [ud setObject:name forKey:@"username"];
    [ud setObject:password forKey:@"password"];
    [ud setObject:loginID forKey:@"loginID"];
    [self performSelectorOnMainThread:@selector(startThread) withObject:nil waitUntilDone:NO];
}

#pragma mark - 获取个推clientID
-(NSString *)GetClientID
{
    return nil;
}

#pragma mark - 向原生中设置数据
-(void)setNativeData:(NSString *)key Value:(NSString *)json
{
    
}

#pragma mark - 获取原生中存储的数据
-(NSString *)getNativeData:(NSString *)keyname
{
    return [ud objectForKey:keyname];
}

#pragma mark - 登出
-(void)logout
{
    [self clear];
    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallRemovePassword();"];
    [context evaluateScript:js];
    [self exitThread];
}

#pragma mark - 获取网络状态
-(int)internetStatus {
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    int result = 0;
    switch (internetStatus) {
        case ReachableViaWiFi:
            result = 1;
            break;
        case ReachableViaWWAN:
            result = 2;
            break;
        case NotReachable:
            result = 0;
            break;
        default:
            break;
    }
    return result;
}

#pragma mark - 清除cookie
-(void)clear
{
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies]) {
        [myCookie deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [ud removeObjectForKey:@"username"];
    [ud removeObjectForKey:@"password"];
    [ud removeObjectForKey:@"random"];
    [ud removeObjectForKey:@"version"];
    [self performSelectorOnMainThread:@selector(exitThread) withObject:nil waitUntilDone:NO];
    autoFlag = YES;
}
#pragma mark - 退出
-(void)Exit
{
}

#pragma mark - 打开地图
-(void)OpenMap
{
    mGDMapView = [[GDMapSelectedView alloc]initWithFrame:self.view.frame];
    [mGDMapView setDelegate:self];
    [self.view addSubview:mGDMapView];
}

#pragma mark - 服务调用及回传
-(void)GetServerData:(NSString *)retEvent Function:(NSString *)function  Data:(NSString *)data LoginId:(NSString *)loginId
{
    [self setContextJs];
    if(timerTimes == 5){
        [timerBund setFireDate:[NSDate distantFuture]];
        timerTimes = 0;
    }
//    NSLog(@"GetserviceData 被调用%@",function);
    if([self internetStatus] == 0)
    {
        [HUDManager showMessage:@"设备未连接到网络！" mode:MBProgressHUDModeText duration:1.5f];
        return;
    }
    
    NSDate *startTime = [NSDate date];
    NSTimeInterval time = [startTime timeIntervalSince1970];
    long long int date = (long long int)time * 1000;
    NSString * ITonce = [NSString stringWithFormat:@"%lld",date];
    NSString *IStr = [[NSString alloc] initWithFormat:@"%@%@%@",loginId,ITonce,@"WSDstarenergy@201510"];
    NSString * ICiphrt = [[IStr sha1] uppercaseString];
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",SE_SERVICEPRE,function];
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    data = [data stringByReplacingOccurrencesOfString:@"@CIPHERTEXT@" withString:ICiphrt];
    data = [data stringByReplacingOccurrencesOfString:@"@TONCE@" withString:ITonce];
    NSData *pData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [PostFunc postData2:pData Url:URL];
    if([str isEqualToString:@""])
        str = [PostFunc postData2:pData Url:URL];
    if(![str isEqualToString:@""] ){
        if([function isEqualToString:@"Login"])
        {
        }
        NSString *js = [NSString stringWithFormat:@"PJO_SE.ServiceCallBack(%@,%@);",retEvent,str];
        [context evaluateScript:js];
    }else{
        [self setContextJs];
        NSString *rMsg =[NSString stringWithFormat:@"{\"Msg\":\"失败\",\"Information\":\"获取数据失败： 无返回值\"}"];
        NSString *js = [NSString stringWithFormat:@"PJO_SE.ServiceCallBack(%@,%@);",retEvent,rMsg];
        [context evaluateScript:js];
    }
}

-(void)GetServerDataEx:(NSString *)retEvent Function:(NSString *)function Data:(NSString*)data LoginId:(NSString *)loginId MethodType:(NSNumber *)methodType
{
    [self setContextJs];
    if(timerTimes == 5){
        [timerBund setFireDate:[NSDate distantFuture]];
        timerTimes = 0;
    }
    //    NSLog(@"GetserviceData 被调用%@",function);
    if([self internetStatus] == 0)
    {
        [HUDManager showMessage:@"设备未连接到网络！" mode:MBProgressHUDModeText duration:1.5f];
        return;
    }
    
    NSDate *startTime = [NSDate date];
    NSTimeInterval time = [startTime timeIntervalSince1970];
    long long int date = (long long int)time * 1000;
    NSString * ITonce = [NSString stringWithFormat:@"%lld",date];
    NSString *IStr = [[NSString alloc] initWithFormat:@"%@%@%@",loginId,ITonce,@"WSDstarenergy@201510"];
    NSString * ICiphrt = [[IStr sha1] uppercaseString];
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",SE_SERVICEPRE,function];
   
    data = [data stringByReplacingOccurrencesOfString:@"@CIPHERTEXT@" withString:ICiphrt];
    data = [data stringByReplacingOccurrencesOfString:@"@TONCE@" withString:ITonce];
    
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *requestStr;
    NSString *str= @"";
    if(methodType != nil)
    {
        switch ([methodType intValue]) {
            case 0://get
                requestStr = [NSString stringWithFormat:@"%@?%@",URLString,data];
                URL = [NSURL URLWithString:requestStr];
                str = [PostFunc GetData2:[NSURLRequest requestWithURL:URL]];
                break;
            case 1:
                str = [PostFunc postData2:[data dataUsingEncoding:NSUTF8StringEncoding] Url:URL];
                break;
            default:
                break;
        }
    }
    if(![str isEqualToString:@""] ){
        if([function isEqualToString:@"Login"])
        {
        }
        NSString *js = [NSString stringWithFormat:@"PJO_SE.ServiceCallBack(%@,%@);",retEvent,str];
        [context evaluateScript:js];
    }else{
        [self setContextJs];
        NSString *rMsg =[NSString stringWithFormat:@"{\"Msg\":\"失败\",\"Information\":\"获取数据失败： 无返回值\"}"];
        NSString *js = [NSString stringWithFormat:@"PJO_SE.ServiceCallBack(%@,%@);",retEvent,rMsg];
        [context evaluateScript:js];
    }
}
#pragma mark 位置选择结果函数定义
//成功 返回
-(void)LocationSelectedResponse:(NSDictionary *)locDc
{
    NSLog(@"lat:%f  long:%f  loc:%@",[locDc[@"latitude"] floatValue],[locDc[@"longitude"] floatValue],locDc[@"location"]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [mGDMapView removeFromSuperview];
    });
    NSString *str = [NSString stringWithFormat:@"{\"ret\":1,\"longitude\":\"%f\",\"latitude\":\"%f\",\"address\":\"%@\"}",[locDc[@"longitude"] floatValue],[locDc[@"latitude"] floatValue],locDc[@"location"]];
    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallLocation(%@);",str];
    [context evaluateScript:js];
    
    
}
//取消
-(void)LocationCancelSelectEvent
{
    NSLog(@"取消位置选择");
    dispatch_sync(dispatch_get_main_queue(), ^{
        [mGDMapView removeFromSuperview];
    });
    NSString *str = [NSString stringWithFormat:@"{\"ret\":0,\"longitude\":\"\",\"latitude\":\"\",\"address\":\"\"}"];
    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallLocation(%@);",str];
    [context evaluateScript:js];
}
#pragma mark 二维码扫描结果函数定义
-(void)QRCodeScanSuccessResponse:(NSString *)qrCode
{
    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallQrcode(%@);",qrCode];
    [context evaluateScript:js];
    NSLog(@"QRCodeScan succedd");
}

-(void)QRCodeScanEventCanceled
{
    NSString *IStr = [NSString stringWithFormat:@"{\"ret\":0,\"qrCode\":\"\"}"];
    NSString *js =[NSString stringWithFormat:@"PJO_SE.CallQrcode(%@);",IStr];
    [context evaluateScript:js];
    NSLog(@"QRCodeScan canceled");
}
@end
