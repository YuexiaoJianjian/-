//
//  JSInvokingOC.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/1/4.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "JSInvokingOC.h"
#import "ViewController.h"

@implementation JSInvokingOC
@synthesize mHandle;


#pragma JSObjectProtocol


-(void)ScanQrcode
{
    ViewController * temp = mHandle;
    [temp startQRScan];
}

-(void)GetLocation
{
    ViewController * temp = mHandle;
    [temp getLocInfo];
}

-(void)Clear
{
    ViewController * temp = mHandle;
    [temp clear];
}

-(void)Logout
{
    ViewController *temp = mHandle;
    [temp logout];
}

-(NSString *)GetLoginData
{
    ViewController * temp = mHandle;
    return [temp getLoginData];
}

-(void)SetLoginData:(NSString *)name :(NSString *)password :(NSString *)loginID
{
    ViewController *temp = mHandle;
    [temp setLoginData:name Password:password loginId:loginID];
}

-(void)SetNativeData:(NSString *)key :(NSString *)json
{
    ViewController *temp = mHandle;
    [temp setNativeData:key Value:json];
}

-(NSString *)GetNativeData:(NSString *)keyname
{
    ViewController *temp = mHandle;
    return [temp getNativeData:keyname];
}

-(void)Exit
{
    [mHandle Exit];
}
-(NSString *)GetClientID
{
    ViewController *temp = mHandle;
    return [temp GetClientID];
}


-(void)GetServerData:(NSString *)retEvent :(NSString *)function :(NSString *)data :(NSString *)loginId
{
    ViewController *temp = mHandle;
    [temp GetServerData:retEvent Function:function Data:data LoginId:loginId];
}

-(void)OpenMap
{
    ViewController *temp = mHandle;
    [temp OpenMap];
}

-(void)GetServerDataEx:(NSString *) retEvent :(NSString *)function :(NSString*)data :(NSString *)loginId :(NSNumber *)methodType
{
    ViewController *temp = mHandle;
    [temp GetServerDataEx:retEvent Function:function Data:data LoginId:loginId MethodType:methodType];
}
@end
