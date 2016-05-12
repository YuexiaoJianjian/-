//
//  CustomCalloutView.m
//  GDMapTest
//
//  Created by 维斯顿 on 16/4/18.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "CustomCalloutView.h"

@implementation CustomCalloutView
@synthesize tipsLabel,title,tips,titleLabel,image,imageView;

-(void)setTips:(NSString *)mTips
{
    tipsLabel.text = mTips;
}

-(void)setTitle:(NSString *)mTitle
{
    titleLabel.text = mTitle;
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    // 添加图片，即商户图
    int kPortraitMargin = 5;
    int kPortraitWidth = 70;
    int kPortraitHeight = 50;
    
    int kTitleHeight = 15;
    int kTitleWidth = 120;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin,kPortraitWidth,kPortraitHeight)];
    [imageView setImage:[UIImage imageNamed:@"switch"]];
    [self addSubview:imageView];
    
    // 添加标题，即商户名
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"titletitletitletitle";
    [self addSubview:self.titleLabel];
    
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight)];
    tipsLabel.font = [UIFont systemFontOfSize:11];
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.text = @"(按住可拖动)";
    [self addSubview:tipsLabel];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//     Drawing code
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    int kArrorHeight = 10;
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

-(void)quitSelect
{
    NSLog(@"quitSelect");
}

@end
