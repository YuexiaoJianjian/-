//
//  YJQRCodeScanView.m
//  扫描二维码、条形码
//
//  Created by chen on 15/7/30.
//  Copyright (c) 2015年 YJ_cn. All rights reserved.
//

#import "YJQRCodeScanView.h"
#import "YJShadowView.h"
#import <AVFoundation/AVFoundation.h>

@interface YJQRCodeScanView()<AVCaptureMetadataOutputObjectsDelegate>//用于处理采集信息的代理
{
    AVCaptureSession * _session;//输入输出的中间桥梁
    ScanType _currentScanType ;
}

@property(nonatomic, copy)ScanSuccess scanSuccess ;
@property(nonatomic, copy)ScanFailed scanFailed ;

@property(nonatomic, weak)YJShadowView *shadowView ;


@end

@implementation YJQRCodeScanView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self shadowView];
       
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //保持阴影的frame和self相同
    [self.shadowView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (YJShadowView *)shadowView{
    if (_shadowView == nil) {
        YJShadowView *shadowView = [[YJShadowView alloc]initWithFrame:self.bounds];
        //默认
        shadowView.clearAreaSize = CGSizeMake(200, 200);
        [self addSubview:shadowView];
        _shadowView = shadowView ;
    }
    return _shadowView;
}

//设置中间透明区域
- (void)setClearAreaSize:(CGSize)clearAreaSize{
    _clearAreaSize = clearAreaSize ;
    self.shadowView.clearAreaSize = clearAreaSize ;
}


#pragma mark -开始扫描

//支持类型

//开始扫描
- (void)startScan{
    
    if (![self validateCamera]) {
        NSLog(@"没有可用的相机");
        if (self.scanFailed) {
            self.scanFailed(@"没有可用的相机");
        }
        return ;
    }
    
    if (_session) {
        [self.shadowView hideActivityIndicatorView];
        [_session stopRunning];
        _session = nil ;
        
        //不是很好的方法： 继续扫描
        if ([self.layer.sublayers[0] isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            [self.layer.sublayers[0] removeFromSuperlayer];
        }
    }

    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    NSError *error ;
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        if (self.scanFailed) {
            self.scanFailed([error localizedDescription]);
        }
        return ;
    }
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //(x,y,w,h)  x：距离左上角的垂直距离,y距离左上角的水平距离 w为高度  h为宽度
    CGPoint clearPoint = self.shadowView.clearRect.origin ;
    CGSize  clearsize  = self.shadowView.clearRect.size ;
    
    //4s 3.5寸屏幕可能有误差
    //设置有效扫描区域
    output.rectOfInterest = CGRectMake(clearPoint.y/self.shadowView.frame.size.height,clearPoint.x/self.shadowView.frame.size.width , clearsize.height/self.shadowView.frame.size.height, clearsize.width/self.shadowView.frame.size.width);
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    if (_currentScanType == ScanType_QRCode){
        [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    }else{ //默认=0 的情况 ，支持全部
     output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    }
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    //充满要显示的view框的
    layer.videoGravity= AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.shadowView.layer.bounds;
    
    
 
//ipad横屏时候的适配
    layer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation:[UIDevice currentDevice].orientation];
//     捕捉输出需要设置
//    AVCaptureConnection *output2VideoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
//    output2VideoConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation:1];
 
    
    [self.layer insertSublayer:layer atIndex:0];
    NSLog(@"%@",layer);
  
    //开始捕获
    [_session startRunning];
    [self.shadowView animationStart];
}

- (BOOL)validateCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}


- (void)stopScan{
    [_session stopRunning];
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects!=nil  &&  metadataObjects.count>0) {
       
        [_session stopRunning];
        [self.shadowView showActivityIndicatorView];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex: 0];
        //输出扫描字符串
        if (self.scanSuccess) {
            self.scanSuccess(metadataObject.stringValue);
        }
        NSLog(@"%@",metadataObject.stringValue);
    }
}



#pragma mark -方法
- (void)startScanWithScanType:(ScanType)scanType succeed:(ScanSuccess)success falied:(ScanFailed)failed{
    
    _currentScanType = scanType ;
    self.scanSuccess = success ;
    self.scanFailed  = failed  ;
    
    [self startScan];
}



/**
 *
 */

- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation:(UIDeviceOrientation )interfaceOrientation {
    switch ([UIDevice currentDevice].orientation) {
        case UIInterfaceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
        default:
            break;
    }
    return AVCaptureVideoOrientationPortrait;
}




@end




