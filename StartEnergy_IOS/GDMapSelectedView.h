//
//  GDMapSelectedView.h
//  Electricity_App
//
//  Created by 维斯顿 on 16/5/10.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CustomAnnotationView.h"

@protocol GDMapSelectedEventsDelegate <NSObject>
@required
-(void)LocationSelectedResponse:(NSDictionary *)locDc;
-(void)LocationCancelSelectEvent;
@end

@interface GDMapSelectedView : UIView <MAMapViewDelegate>
{
    MAMapView *mMapView;
    MAPointAnnotation *pointAnnotation;
    int status;
}

@property (nonatomic,assign) id<GDMapSelectedEventsDelegate> delegate;

@end
