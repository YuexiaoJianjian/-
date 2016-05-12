//
//  CustomAnnotationView.h
//  GDMapTest
//
//  Created by 维斯顿 on 16/4/18.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CustomCalloutView.h"

@interface CustomAnnotationView : MAPinAnnotationView
@property (nonatomic,readonly) CustomCalloutView *calloutView;
@end
