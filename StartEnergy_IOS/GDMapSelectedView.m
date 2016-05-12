//
//  GDMapSelectedView.m
//  Electricity_App
//
//  Created by 维斯顿 on 16/5/10.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "GDMapSelectedView.h"

@implementation GDMapSelectedView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        //Map
        [self OpenMap:frame];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - 打开地图
-(void)OpenMap:(CGRect)frame
{
    status = 0;
    [MAMapServices sharedServices].apiKey = @"c8798dddd2845bbbd04ee9ceb8743a52";
    mMapView = [[MAMapView alloc]initWithFrame:frame];
    mMapView.delegate = self ;
    mMapView.showsCompass = NO;
    mMapView.scaleOrigin = CGPointMake(mMapView.scaleOrigin.x, 22);
    mMapView.zoomLevel = 18;
    mMapView.showsUserLocation = YES;
    [mMapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 + 64 , frame.size.height - 84, 64, 64)];
    [btn setImage:[UIImage imageNamed:@"CuteBall-Favorites002"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(quitSelect_ok) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 -64*2 ,frame.size.height - 84, 64, 64)];
    [btn2 setImage:[UIImage imageNamed:@"CuteBall-Favorites010"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(quitSelect_cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:mMapView];
    [mMapView addSubview:btn2];
    [mMapView addSubview:btn];
}

-(void)quitSelect_cancel{
    [mMapView removeFromSuperview];
    [self.delegate LocationCancelSelectEvent];
}

-(void)quitSelect_ok{
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    CLLocation *loca = [[CLLocation alloc]initWithLatitude:pointAnnotation.coordinate.latitude longitude:pointAnnotation.coordinate.longitude];
    [geoCoder reverseGeocodeLocation:loca completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            NSString *provin = [placemark administrativeArea];//省
            NSString *city  =[placemark locality]; // 市
            NSString *street =[placemark thoroughfare];//街道
            NSString *subLocality =[placemark subLocality];//区
            NSString *subThoroughfare = [placemark subThoroughfare];//门号
            NSString *loc = [NSString stringWithFormat:@"%@%@%@%@%@",provin,city,subLocality,street,subThoroughfare];

            NSNumber *lat =[NSNumber numberWithFloat:pointAnnotation.coordinate.latitude];
            NSNumber *lot =[NSNumber numberWithFloat:pointAnnotation.coordinate.longitude];
            NSDictionary *locDc = @{@"latitude":lat,@"longitude":lot,@"location":loc};
            [self.delegate LocationSelectedResponse:locDc];
        }
    }];
}

// 位置更新
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        
        if(status == 0){
            pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
            [mMapView addAnnotation:pointAnnotation];
            status = 1;
        }
    }
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        annotationView.canShowCallout= NO;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}



@end
