//
//  PostFunc.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/3/11.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "PostFunc.h"
#import "JSONKit.h"

@implementation PostFunc

+(int)postData:(NSDictionary *)data Url:(NSURL *)url
{
    NSError *parseError = nil;
    
    NSData* postData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&parseError];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"post"]; //指定请求方式
    [request setURL:url]; //设置请求的地址
    [request setHTTPBody:postData];  //设置请求的参数
    [request setValue: @"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setTimeoutInterval:20.0f];
    NSURLResponse * response;
    NSError * error;
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return -2;//post出错
    }else{
        if(backData != nil)
        {
            NSError * tError;
            NSString *aString = [[NSString alloc] initWithData:backData encoding:NSUTF8StringEncoding];
            aString = [aString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
            NSData* jsonData = [aString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *heartInfo = [jsonData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode error:&tError];
            //匹配 返回1
            if(heartInfo != nil){
                NSString *msgRes = [heartInfo objectForKey:@"Msg"];
                if([msgRes isEqualToString:@"成功"])
                    return 1;
                else
                    return 0;
            }
            //不匹配 返回0
        }
        return -1;//返回数据空
    }
}


+(int)postDataCid:(NSDictionary *)data Url:(NSURL *)url
{
    NSError *parseError = nil;
    NSData* postData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&parseError];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"post"]; //指定请求方式
    [request setURL:url]; //设置请求的地址
    [request setHTTPBody:postData];  //设置请求的参数
    [request setValue: @"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setTimeoutInterval:20.0f];
    NSURLResponse * response;
    NSError * error;
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return -2;//post出错
    }else{
        if(backData != nil)
        {
            NSError * tError;
            NSString *aString = [[NSString alloc] initWithData:backData encoding:NSUTF8StringEncoding];
            aString = [aString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
            NSData* jsonData = [aString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *heartInfo = [jsonData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode error:&tError];
            //匹配 返回1
            if(heartInfo != nil){
                NSString *msgRes = [heartInfo objectForKey:@"Msg"];
                if([msgRes isEqualToString:@"成功"])
                {
                    NSNumber *status = [heartInfo objectForKey:@"Status"];
                    return [status intValue];
                }
                else
                    return 0;
            }
            //不匹配 返回0
        }
        return -1;//返回数据空
    }
}

+(NSString *)postData2:(NSData *)data Url:(NSURL *)url
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"post"]; //指定请求方式
    [request setURL:url]; //设置请求的地址
    [request setHTTPBody:data];  //设置请求的参数
    [request setValue: @"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0f];
    NSURLResponse * response;
    NSError * error;
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(backData != nil)
    {
        NSString *aString = [[NSString alloc] initWithData:backData encoding:NSUTF8StringEncoding];
        aString = [aString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
        return aString;
    }
    return [NSString stringWithFormat:@""];
}


+(int)GetData:(NSURLRequest *)request
{
    NSError *error;
    NSData *requestData= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        NSLog(@"错误信息:%@",[error localizedDescription]);
        return -1;
    }else{
        if(requestData != nil)
        {
            NSError * tError;
            NSString *aString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
            aString = [aString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
            NSData* jsonData = [aString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *heartInfo = [jsonData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode error:&tError];
            //匹配 返回1
            if(heartInfo != nil){
                NSString *msgRes = [heartInfo objectForKey:@"Msg"];
                if([msgRes isEqualToString:@"成功"])
                    return 1;
                else
                    return 0;
            }
            //不匹配 返回0
        }
        return -1;//返回数据空
        
        return 1;
        
    }
}
+(NSString *)GetData2:(NSURLRequest *)request
{
    NSError *error;
    NSData *requestData= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(requestData != nil)
    {
        NSString *aString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        aString = [aString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
        return aString;
    }
    return [NSString stringWithFormat:@""];
}


@end
