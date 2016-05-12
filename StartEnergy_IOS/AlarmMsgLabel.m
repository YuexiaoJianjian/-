//
//  AlarmMsgLabel.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/3/11.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "AlarmMsgLabel.h"

@implementation AlarmMsgLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setText:@"您有新的告警信息"];
    [self setTextAlignment:NSTextAlignmentCenter];
    [self setBackgroundColor:[UIColor redColor]];
    [self setAlpha:0.9f];
    [self setTextColor:[UIColor whiteColor]];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
