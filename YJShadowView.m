//
//  YJShadowView.m
//  二维码扫描界面view
//
//  Created by chen on 15/7/29.
//  Copyright (c) 2015年 YJ_cn. All rights reserved.
//

#import "YJShadowView.h"
#import <QuartzCore/QuartzCore.h>
@interface YJShadowView(){
//    CGRect _clearRect ;
    
    CGPoint _startPoint ;
    CGPoint _endPoint ;
}

@property(nonatomic, assign)CGRect clearRect;


@property(nonatomic, weak)UIImageView *scanLine;
@property(nonatomic, weak)UIActivityIndicatorView *activityView;


@end

@implementation YJShadowView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         self.backgroundColor = [UIColor clearColor];
        //当做默认
        [self setClearAreaSize:CGSizeMake(200, 200)];
        [self activityView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //改变frame时候更新下 起点和重点位置
    [self points_Init];
}


- (void)setClearAreaSize:(CGSize)clearAreaSize{
    _clearAreaSize = clearAreaSize ;
    
    [self points_Init];
}

- (void)points_Init{
    //放在中心位置
    _clearRect = CGRectMake((self.frame.size.width-self.clearAreaSize.width)/2, (self.frame.size.height-self.clearAreaSize.height)/2, self.clearAreaSize.width, self.clearAreaSize.height);
    
    _startPoint = CGPointMake(_clearRect.origin.x+_clearRect.size.width/2.0, _clearRect.origin.y);
    _endPoint   = CGPointMake(_clearRect.origin.x+_clearRect.size.width/2.0, _clearRect.origin.y+_clearRect.size.height);
}



#pragma mark - 等待状态菊花视图

- (void)showActivityIndicatorView{
    [self.activityView startAnimating];
    [self performSelector:@selector(animationStop) withObject:self afterDelay:0.01];
}

- (void)hideActivityIndicatorView{
    [self.activityView stopAnimating];
}

- (void)dealloc{
    NSLog(@"dealloc");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationStop) object:nil];
}


- (UIActivityIndicatorView *)activityView{
    if (_activityView == nil) {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.center = self.center ;
        [self addSubview:activity];
        _activityView = activity ;
    }
    return _activityView;
}

#pragma mark - 滚动的线
- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
    //[self animationStart];
}

#pragma mark - 动画开始和移除
- (void)animationStart{
    self.scanLine.hidden = NO ;
    [self animationFromPoint:_startPoint toPoint:_endPoint];
}
- (void)animationStop{
    self.scanLine.hidden = YES;
    [self.scanLine.layer removeAllAnimations];
}

#pragma mark - 扫描线的动作
- (void)animationFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position";
    NSValue *v1 = [NSValue valueWithCGPoint:point1];
    NSValue *v2 = [NSValue valueWithCGPoint:point2];
    anim.values = @[v1,v2];
    anim.duration = 2;
    anim.repeatCount = MAXFLOAT;
    [self.scanLine.layer addAnimation:anim forKey:nil];
}

#pragma mark -
- (UIImageView *)scanLine{
    if (_scanLine == nil) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan"]];
         [self addSubview:imageView];
        _scanLine = imageView;
        self.scanLine.hidden = YES ;
    }
    return _scanLine ;
}


#pragma mark - 主界面
- (void)drawRect:(CGRect)rect{
//    CGRect clearRect = CGRectMake((rect.size.width-self.clearAreaSize.width)/2, (rect.size.height-self.clearAreaSize.height)/2, self.clearAreaSize.width, self.clearAreaSize.height);
    
    [self points_Init];
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //view的默认颜色
    [self addScreenFillRect:ctx rect:rect];
    //透明区域
    CGContextClearRect(ctx, _clearRect);
    //绘制透明区域的白色边线
    [self addWhiteRect:ctx rect:_clearRect];
    //四个绿角
    [self addCornerLineWithContext:ctx rect:_clearRect];
}


- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 20/ 255.0,68/ 255.0,106 / 255.0,0.5);
    //[[UIColor lightGrayColor]  setFill];
    CGContextFillRect(ctx, rect);
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83 /255.0, 239/255.0, 111/255.0, 1);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}


- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}



@end


















