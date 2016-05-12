//
//  YJShadowView.h
//  二维码扫描界面view
//
//  Created by chen on 15/7/29.
//  Copyright (c) 2015年 YJ_cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJShadowView : UIView


@property (nonatomic, assign) CGSize clearAreaSize;

@property(nonatomic, assign,readonly)CGRect clearRect;


- (void)animationStart;
- (void)animationStop;

- (void)showActivityIndicatorView;
- (void)hideActivityIndicatorView;



@end


/*
 YJShadowView *view = [[YJShadowView alloc]initWithFrame:self.view.bounds];
 [self.view addSubview:view];
 NSLog(@"%@",NSStringFromCGSize(view.clearAreaSize));
 view.clearAreaSize = CGSizeMake(200, 200);
 
 view.backgroundColor = [UIColor clearColor];
 
 self.view.backgroundColor = [UIColor  whiteColor];
 */