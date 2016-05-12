//
//  UpdateViewsFunc.m
//  StartEnergy_IOS
//
//  Created by 维斯顿 on 16/3/11.
//  Copyright © 2016年 维斯顿. All rights reserved.
//

#import "UpdateViewsFunc.h"
#import <CommonCrypto/CommonCrypto.h>
#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation UpdateViewsFunc
{

}
@synthesize WebFileConfigFileName,RemoteAddr;

#pragma mark - 获取document文件夹路径
-(NSString *)GetDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    return documentPath;
}

#pragma mark - 获取resource文件夹路径
-(NSString *)GetResourcePath
{
    NSString* resourcePath = [[NSBundle mainBundle]resourcePath];
    return resourcePath;
}

#pragma mark - 复制文件
-(BOOL)CopyFileFrom:(NSString *)source To:(NSString *)dest
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager copyItemAtPath:source toPath:dest error:nil];
}

#pragma mark - 检查文件在document文件夹中是否存在
-(BOOL)CheckFileIsExist:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[self GetDocumentPath] stringByAppendingPathComponent:fileName];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    return isExist;
}

#pragma mark - 复制WebFileConfig文件
-(BOOL)CopyConfigFileFromResource
{
    if(WebFileConfigFileName == nil)
        WebFileConfigFileName = [NSString stringWithFormat:@"webfileconfigure.txt"];
    if(![self CheckFileIsExist:WebFileConfigFileName])
    {
        NSString* defaultPath = [[self GetResourcePath] stringByAppendingPathComponent:WebFileConfigFileName];
        NSString* dest = [[self GetDocumentPath] stringByAppendingString:WebFileConfigFileName];
        return [self CopyFileFrom:defaultPath To:dest];
    }else{
        return YES; //已存在返回成功，不复制
    }
}

#pragma mark - 创建文件夹
-(BOOL)CreateFinder:(NSString *)finderName
{
    NSString *path = [[self GetDocumentPath] stringByAppendingPathComponent:finderName];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - 复制网页文件
-(BOOL)CopyWebFileFromResource
{
    NSString *documentPath = [self GetDocumentPath];
    NSString *resourcePath = [self GetResourcePath];
    NSDictionary *jsonObject = [self GetConfigData];
    for(NSDictionary *dic in jsonObject)
    {
        NSString *pack = dic[@"Path"];
        NSString *file;
        if([pack isEqualToString:@""])
            file = [NSString stringWithFormat:@"%@",dic[@"Name"]];
        else{
            pack = [pack stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            [self CreateFinder:pack];
            file = [NSString stringWithFormat:@"%@/%@",pack,dic[@"Name"]];
        }
        //resource
        NSString *tempPath = [resourcePath stringByAppendingPathComponent:file];
        //destination
        NSString *tempDest = [documentPath stringByAppendingPathComponent:file];
        if(![self CheckFileIsExist:file])
        {
            if(![self CopyFileFrom:tempPath To:tempDest])
            {
                //                NSLog(@"本地 复制 %@ 出错！",file);
            }
        }
    }
    return YES;
}

#pragma mark - 获取本地配置信息
-(NSMutableDictionary *)GetConfigData
{
    NSString *documentPath = [self GetDocumentPath];
    NSString *ConfigFilePath = [documentPath stringByAppendingPathComponent:WebFileConfigFileName];
    if([self CheckFileIsExist:WebFileConfigFileName])
    {
        NSData* data = [NSData dataWithContentsOfFile:ConfigFilePath];
        NSError *error = nil;
        NSMutableDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        return jsonObject;
    }
    return nil;
}

#pragma  mark - MD5信息保存到字典中
-(void)saveMD5List
{
    fileMsgList = [self GetConfigData];
    if(fileMD5List == nil)
        fileMD5List = [[NSMutableDictionary alloc]init];
    if(downloadState == nil)
        downloadState = [[NSMutableDictionary alloc]init];
    [fileMD5List removeAllObjects];
    [downloadState removeAllObjects];
    for(NSDictionary *dic in fileMsgList){
        NSString *path = [NSString stringWithFormat:@"%@/%@",dic[@"Path"],dic[@"Name"]];
        [fileMD5List setValue:dic[@"MD5"] forKey:path];
        [downloadState setValue:[NSNumber numberWithInt:0]forKey:path];
    }
}

#pragma mark - 获取服务器端配置信息
-(NSDictionary *)GetRemoteConfigData
{
    if(RemoteAddr == nil)
        RemoteAddr = [NSString stringWithFormat:@"http://192.168.1.203:8010"];
    NSString *path = [RemoteAddr stringByAppendingPathComponent:WebFileConfigFileName];
    NSData *data = [self requestDataFromRemotePath:path];
    NSError *error = nil;
    if(data == nil)
        return nil;
    NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return jsonObject;
    
}

#pragma mark - 获取服务器网页文件
-(void)GetRemoteWebFile
{
    array = [[NSMutableArray alloc]init];
    if(RemoteAddr == nil)
        RemoteAddr = [NSString stringWithFormat:@"http://192.168.1.203:8010"];
    NSDictionary *remoteData;
    [self saveMD5List]; //更新本地md5列表
    remoteData = [self GetRemoteConfigData];
    if(remoteData != nil)
    {
        
        for(NSDictionary *dic in remoteData)
        {
            NSString *tPath = [NSString stringWithFormat:@"%@/%@",dic[@"Path"],dic[@"Name"]];
            if(![self CompareMD5:dic[@"MD5"] AndName:fileMD5List[tPath]]){
                
                NSString *pack = dic[@"Path"];
                NSString *file;
                if([pack isEqualToString:@""])
                    file = [NSString stringWithFormat:@"%@",dic[@"Name"]];
                else{
                     pack = [pack stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    if(![self CreateFinder:pack]) //创建文件夹
                    {
                        //NSLog(@"创建文件夹 %@ 失败",pack);
                    }
                    file = [NSString stringWithFormat:@"%@/%@",pack,dic[@"Name"]];
                }
                NSString *tempPath = [RemoteAddr stringByAppendingPathComponent:file];
                NSData * data = nil;
                int times = 0,status = 0;
                while(data == nil || ![self CompareMD5:[self GetMD5WithData:data] AndName:dic[@"MD5"]])
                {
                    if(times++ > 3){
                        status = 1;
                        break;
                    }
                    data = [self requestDataFromRemotePath:tempPath];
                }
                
                if(status == 0){
                    if(![data writeToFile:[[self GetDocumentPath] stringByAppendingPathComponent:file] atomically:YES]){
                            [downloadState setValue:[NSNumber numberWithInt:2] forKey:tPath];
                        }
                    else{
                            NSLog(@"下载成功%@",file);
                            if(fileMD5List[tPath] == nil)
                            {
                                NSMutableDictionary *obj = [[NSMutableDictionary alloc]init];
                                [obj setValue:dic[@"Path"] forKey:@"Path"];
                                [obj setValue:dic[@"Name"] forKey:@"Name"];
                                [obj setValue:dic[@"MD5"] forKey:@"MD5"];
                                [array addObject:obj];
                            }
                            NSString *tt = [NSString stringWithFormat:@"%@",dic[@"MD5"]];
                            [fileMD5List setValue:tt forKey:tPath];
                            [downloadState setValue:[NSNumber numberWithInt:1] forKey:tPath];
                    }
                }else{
                    NSLog(@"获取数据失败 %@",file);
                    [downloadState setValue:[NSNumber numberWithInt:3] forKey:tPath];
                }
            }
        }
    }
}

#pragma mark - request请求数据
-(NSData *)requestDataFromRemotePath:(NSString *)path
{
    NSURL    *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url  cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0f];
    NSError *error = nil;
    NSData   *data = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:nil error:&error];
    return data;
}

#pragma mark - 比较md5值
-(BOOL)CompareMD5:(NSString *)md5 AndName:(NSString *)name
{
    if(name != nil)
        return [name isEqualToString:md5];
    return NO;
}

#pragma mark - 计算md5值
-(NSString *)GetMD5WithData:(NSData *)data
{
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, [data bytes], [data length]);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

#pragma mark - 保存webfile信息
-(void)SavaWebfileCongfigFile
{
    @try{
    NSMutableDictionary *saveList = [[NSMutableDictionary alloc]init];
    for(NSDictionary *dic in fileMsgList)
    {
        NSString *tPath = [NSString stringWithFormat:@"%@/%@",dic[@"Path"],dic[@"Name"]];
        NSMutableDictionary *obj = [[NSMutableDictionary alloc]init];
        NSNumber *t = [downloadState objectForKey:tPath];
        if(t != nil && [t intValue] == 1){
            [obj setValue:[fileMD5List objectForKey:tPath] forKey:@"MD5"];
        }else
        {
            [obj setValue:dic[@"MD5"] forKey:@"MD5"];
        }
        [obj setObject:dic[@"Name"] forKey:@"Name"];
        [obj setObject:dic[@"Path"] forKey:@"Path"];
        [array addObject:obj];
    }
   if(array == nil)
       return;
    [saveList setObject:array forKey:@""];
    NSError *Error = nil;
    NSData* fileData = [NSJSONSerialization dataWithJSONObject:saveList options:NSJSONWritingPrettyPrinted error:&Error];
    NSMutableString *strData = [[NSMutableString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
    NSRange range = [strData rangeOfString:@":"];
    [strData deleteCharactersInRange:NSMakeRange(0,range.location+1)];
    [strData deleteCharactersInRange:NSMakeRange(strData.length-1, 1)];
    fileData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dest = [[self GetDocumentPath] stringByAppendingPathComponent:WebFileConfigFileName];
    if(![fileData writeToFile:dest atomically:YES]){
        if(![fileData writeToFile:dest atomically:YES])
        {
            NSLog(@"----------------------保存webfileCongfig 文件失败 ----------------------------");
        }
    }
    }@catch(NSException *e)
    {
        NSLog(@"%@",e.description);
    }
    
}

@end
