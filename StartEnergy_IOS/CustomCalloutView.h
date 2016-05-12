//
//  CustomCalloutView.h
//  GDMapTest
//
//  Created by 维斯顿 on 16/4/18.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCalloutView : UIView

@property (nonatomic,strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *tips;

@end
