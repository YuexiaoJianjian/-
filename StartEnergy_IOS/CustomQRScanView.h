//
//  QRScanView.h
//  Electricity_App
//
//  Created by 维斯顿 on 16/5/10.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJQRCodeScanView.h"
#import <AVFoundation/AVFoundation.h>

@protocol QRCodeScanEventsDelegate <NSObject>

@required
-(void)QRCodeScanSuccessResponse:(NSString *)qrCode;
-(void)QRCodeScanEventCanceled;
@end

@interface CustomQRScanView : UIView
@property (nonatomic,assign) id<QRCodeScanEventsDelegate> delegate;
@property (nonatomic,weak) YJQRCodeScanView *qrScanView;
@end
