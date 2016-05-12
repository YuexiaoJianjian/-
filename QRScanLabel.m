//
//  QRScanLabel.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/3/11.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "QRScanLabel.h"

@implementation QRScanLabel
-(void)SetInitFrame:(CGRect) frame
{
    [self setFrame:frame];
    [self setText:@"请将二维码置于方框中"];
    [self setTextColor:[UIColor colorWithRed:95 green:190 blue:125 alpha:1]];
    [self setTextAlignment:NSTextAlignmentCenter];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
