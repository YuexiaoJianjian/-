//
//  UpdateViewsFunc.h
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/3/11.
//  Copyright © 2016年 维斯顿. All rights reserved.
//
/*
 1 赋值WebFileConfigFileName，RemoteAddr；
 2 复制配置文件
 3 复制网页文件
 4 获取服务器网页文件
 5 获取服务器配置文件
 */
#import <Foundation/Foundation.h>

@interface UpdateViewsFunc : NSObject
{
    NSMutableDictionary *fileMD5List;
    NSMutableDictionary *downloadState;
    NSMutableDictionary *fileMsgList;
    NSMutableArray *array;
    
}
@property (nonatomic,weak) NSString *WebFileConfigFileName;
@property (nonatomic,weak) NSString *RemoteAddr;
-(BOOL)CheckFileIsExist:(NSString *)fileName;
-(NSString *)GetDocumentPath;
-(BOOL)CopyConfigFileFromResource;//复制WebFileConfig文件
-(BOOL)CopyWebFileFromResource;//复制网页文件
-(void)GetRemoteWebFile;//获取服务器网页文件
-(void)SavaWebfileCongfigFile;
@end
