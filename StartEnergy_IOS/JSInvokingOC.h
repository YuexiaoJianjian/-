//
//  JSInvokingOC.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/1/4.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjectProtocol <JSExport>

-(void)ScanQrcode;
-(void)GetLocation;
-(void)Clear;
-(void)Logout;
-(NSString *)GetLoginData;
-(void)SetLoginData:(NSString *)name :(NSString *)password :(NSString *)loginID;
-(void)SetNativeData:(NSString *)key :(NSString *)json;
-(NSString *)GetNativeData:(NSString *)keyname;
-(void)Exit;
-(void)GetServerData:(NSString *)retEvent :(NSString *)function :(NSString *)data :(NSString *)loginId;
-(void)GetServerDataEx:(NSString *) retEvent :(NSString *)function :(NSString*)data :(NSString *)loginId :(NSNumber *)MethodType;
-(void)OpenMap;

@end

@interface JSInvokingOC : NSObject<JSObjectProtocol>


@property (nonatomic,weak) id mHandle;

@end
