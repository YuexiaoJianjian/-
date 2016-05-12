//
//  Sha_NSString.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/1/13.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (encrypto)
- (NSString *) md5;
- (NSString *) sha1;
@end
