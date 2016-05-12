//
//  YJQRCodeScanView.h
//  扫描二维码、条形码
//
//  Created by chen on 15/7/30.
//  Copyright (c) 2015年 YJ_cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScanSuccess)(NSString *string);
typedef void(^ScanFailed)(NSString *errorMessage);

typedef enum : NSUInteger {
    ScanType_Normal = 0,
    ScanType_QRCode,
} ScanType;

@interface YJQRCodeScanView : UIView

@property (nonatomic, assign) CGSize clearAreaSize;

- (void)startScan;
- (void)stopScan;

- (void)startScanWithScanType:(ScanType)scanType succeed:(ScanSuccess)success falied:(ScanFailed)failed;



@end
