//
//  UpdateViewController.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/4/9.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateViewsFunc.h"

////#define DEBUG 1
//#ifdef DEBUG
//#define kGtAppId           @"HE1s6S2WBu6ytMWgwHB2g1"
//#define kGtAppKey          @"ApAL3GGrBvArgDecFEZpD5"
//#define kGtAppSecret       @"F0WKiEz2hH9u5Jj0wYEIy5"
//#define SE_HOSTLOGIN @"http://192.168.1.203:8010/"
////#define SE_HOSTLOGIN @"http://192.168.1.115:8081"
//#else

#define SE_HOSTLOGIN @"http://192.168.1.116:8000/"
//#endif

@interface UpdateViewController :
    UIViewController
{
    UpdateViewsFunc *update;
    NSThread *mThread;
    NSUserDefaults *ud;
}
@property (weak, nonatomic) IBOutlet UILabel *UpdateMsg;
@property (weak, nonatomic) IBOutlet UILabel *ProcessPoint;

@end
