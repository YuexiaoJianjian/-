//
//  CustomAnnotationView.m
//  GDMapTest
//
//  Created by 维斯顿 on 16/4/18.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "CustomAnnotationView.h"
#define kCalloutWidth       200.0
#define kCalloutHeight      70.0
@interface CustomAnnotationView()
@property (nonatomic, strong, readwrite) CustomCalloutView *calloutView;
@end
@implementation CustomAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self.calloutView == nil)
    {
        self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
        self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                              -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
    }
    
    [self.calloutView setTips:@"(按住大头针可拖动)"];
    self.calloutView.title = @"申报故障地点选择";
    [self addSubview:self.calloutView];
    self.selected = NO;
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
