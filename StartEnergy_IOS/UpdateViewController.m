//
//  UpdateViewController.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/4/9.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "UpdateViewController.h"
#import "AppDelegate.h"

#define WEBFILECONGIG @"webfileconfigure.txt"

@interface UpdateViewController ()
{
    BOOL threadRun;
    int points;
}

@end

@implementation UpdateViewController
@synthesize UpdateMsg,ProcessPoint;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    threadRun = NO;
    points = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SaveCid:) name:NOTIFICATION_POST_CID object:nil];
    
    ud = [NSUserDefaults standardUserDefaults];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   [self performSelectorOnMainThread:@selector(startThread1) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(startThread2) withObject:nil waitUntilDone:NO];
}


-(void)SaveCid:(NSNotification *)data
{
    NSDictionary *dic = data.userInfo;
    if(dic == nil)
        return;
    NSString *cid = dic[@"CID"];
    if(cid != nil)
       [ud setObject:cid forKey:@"CID"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startThread1
{
    threadRun = YES;
    mThread = [[NSThread alloc]initWithTarget:self selector:@selector(UpdateFile) object:nil];
    [mThread start];
}

-(void)startThread2
{
    threadRun = YES;
    NSThread *tThread = [[NSThread alloc]initWithTarget:self selector:@selector(UpdateFile2) object:nil];
    [tThread start];
}


//关闭线程
-(void)exitThread
{
    threadRun = NO;
}
-(void)UpdateFile
{
    update = [[UpdateViewsFunc alloc]init];
    [update setWebFileConfigFileName:WEBFILECONGIG];
    [update setRemoteAddr:SE_HOSTLOGIN];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [UpdateMsg setText:@"正在获取文件"];
    });
    [update GetRemoteWebFile];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [UpdateMsg setText:@"正在保存配置信息"];
    });
    [update SavaWebfileCongfigFile];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [UpdateMsg setText:@"更新完成"];
    });
    [self exitThread];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"MainWebView" sender:nil];
    });
    
}

-(void)UpdateFile2
{
        while(threadRun){
            dispatch_sync(dispatch_get_main_queue(), ^{
                switch (points) {
                    case 0:
                        [ProcessPoint setText:@"."];break;
                    case 1:
                        [ProcessPoint setText:@".."];break;
                    case 2:
                        [ProcessPoint setText:@"..."];break;
                    case 3:
                        [ProcessPoint setText:@"...."];break;
                    case 4:
                        [ProcessPoint setText:@"....."];break;
                }
                if(++points == 5)
                    points = 0;
    
    
            });
            [NSThread sleepForTimeInterval:0.8f];
        }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
