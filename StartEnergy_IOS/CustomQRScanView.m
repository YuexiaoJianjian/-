//
//  QRScanView.m
//  Electricity_App
//
//  Created by 维斯顿 on 16/5/10.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "CustomQRScanView.h"
#import "QRScanLabel.h"


@implementation CustomQRScanView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        YJQRCodeScanView *codeView = [[YJQRCodeScanView alloc]initWithFrame:self.bounds];
        [self addSubview:codeView];
        self.qrScanView = codeView ;
            
            // 文字提示
        QRScanLabel *label =[[QRScanLabel alloc]init];
        [label SetInitFrame:CGRectMake(0, 60, self.frame.size.width, 30)];
        [self.qrScanView addSubview:label];
            // 按钮 cancel
        UIButton *btn_Cancel = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2+72,self.frame.size.height - 60, 48, 48)];
        [btn_Cancel setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
            
            // 按钮 灯光
        UIButton *btn_Flash = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2-120,self.frame.size.height - 60, 48, 48)];
        [btn_Flash setBackgroundImage:[UIImage imageNamed:@"falsh.png"] forState:UIControlStateNormal];
            
        [btn_Flash addTarget:self action:@selector(openFlashlight:) forControlEvents:UIControlEventTouchUpInside];
        [btn_Cancel addTarget:self action:@selector(quitScan) forControlEvents:UIControlEventTouchUpInside] ;
        [self.qrScanView addSubview:btn_Cancel];
        [self.qrScanView addSubview:btn_Flash];
            //默认是 200 ,200
        codeView.backgroundColor = [UIColor colorWithRed:96 green:143 blue:159 alpha:1];
        codeView.clearAreaSize = CGSizeMake(250, 250);
    }
    [self startQRScan];
    return self;
}


-(void)startQRScan
{
    [self startScan];
}
//结束扫描
-(void)quitScan
{
    [self.qrScanView stopScan];
    [self.qrScanView removeFromSuperview];
    [self.delegate QRCodeScanEventCanceled];
}
//开始扫描
- (void)startScan{
    [self.qrScanView  startScanWithScanType:ScanType_Normal succeed:^(NSString *string) {
        [self.qrScanView removeFromSuperview];
        NSString *IStr = [NSString stringWithFormat:@"{\"ret\":1,\"qrCode\":\"%@\"}",string];
        [self.delegate QRCodeScanSuccessResponse:IStr];
    } falied:^(NSString *errorMessage) {
        //失败  返回到js消息
        [self.qrScanView removeFromSuperview];
        [self.delegate QRCodeScanEventCanceled];
    }];
}

//闪光灯
-(void)openFlashlight:(UIButton *)sender
{
    sender.selected = !sender.selected;
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (sender.selected) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}


@end
