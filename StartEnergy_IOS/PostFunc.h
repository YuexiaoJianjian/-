//
//  PostFunc.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/3/11.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostFunc : NSObject
+(int)postData:(NSDictionary *)data Url:(NSURL *)url;
+(NSString *)postData2:(NSData *)data Url:(NSURL *)url;
+(int)postDataCid:(NSDictionary *)data Url:(NSURL *)url;

+(int)GetData:(NSURLRequest *)request;
+(NSString *)GetData2:(NSURLRequest *)request;

@end
