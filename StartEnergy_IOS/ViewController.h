//
//  ViewController.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 15/12/30.
//  Copyright © 2015年 维斯顿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "YJQRCodeScanView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <WebKit/WebKit.h>
#import "JSONKit.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AlarmMsgLabel.h"
#import "UpdateViewsFunc.h"
#import "MBProgressHUDManager.h"
#import "GDMapSelectedView.h"
#import "CustomQRScanView.h"


//#import "JSONKit.h"

@interface ViewController : UIViewController <UIWebViewDelegate,CLLocationManagerDelegate,MAMapViewDelegate,AMapLocationManagerDelegate,UIGestureRecognizerDelegate,GDMapSelectedEventsDelegate,QRCodeScanEventsDelegate>
{
    UIWebView *mWebView;
    BOOL mLoading;
    UIButton *btn_Flash;
    JSContext *context;
    NSUserDefaults *ud;
    int debug ;
    BOOL finishLoad;
    BOOL autoLogin;
    BOOL autoFlag;
    NSTimer *mtimer;
    NSThread *myThread;
    BOOL threadRun;
    UISwipeGestureRecognizer *swipeGesture;
    NSTimer *timer,*timerBund;
    UIView *mView;
    UILabel *badge ;
    //BOOL loadError;
    AlarmMsgLabel *msg;
    int timerTimes;
    MBProgressHUDManager *HUDManager;
    MAMapView *mMapView;
    MAPointAnnotation *pointAnnotation;
    int status;
    GDMapSelectedView *mGDMapView;
    CustomQRScanView *mCustomQRView;
}
@property (nonatomic,strong) AMapLocationManager *aMapLocationManager;
@property (nonatomic,weak) YJQRCodeScanView *qrScanView;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (strong,nonatomic) NSString *CID;
-(int)internetStatus;

//js oc 交互
-(void)startQRScan;
-(void)getLocInfo;
-(void)clear;
-(void)logout;
-(NSString *)getLoginData;
-(void)setLoginData:(NSString *)name Password:(NSString *)password loginId:(NSString *)loginID;
-(void)setNativeData:(NSString *)key Value:(NSString *)json;
-(NSString *)getNativeData:(NSString *)keyname;
-(void)Exit;
-(NSString *)GetClientID;
-(void)GetServerData:(NSString *)retEvent Function:(NSString *)function Data:(NSString *)data LoginId:(NSString *)loginId;
-(void)GetServerDataEx:(NSString *)retEvent Function:(NSString *)function Data:(NSString*)data LoginId:(NSString *)loginId MethodType:(NSNumber *)methodType;
-(void)OpenMap;
@end

