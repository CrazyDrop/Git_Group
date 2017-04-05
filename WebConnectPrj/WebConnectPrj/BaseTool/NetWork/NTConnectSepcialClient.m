//
//  NTConnectSepcialClient.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "NTConnectSepcialClient.h"
#import "JSONKit.h"
@implementation NTConnectSepcialClient
//方便快速调用
-(id)init
{
    self =[super init];
    if (self) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}
+(instancetype)sharedNTConnectSepcialClient
{
    static NTConnectSepcialClient *  _SharedNTConnectSepcialClient = nil;
    if (!_SharedNTConnectSepcialClient)
    {
        _SharedNTConnectSepcialClient = [[NTConnectSepcialClient alloc] init];
    }
    
    return _SharedNTConnectSepcialClient;
}

-(void)specialRequestWithBasicRequest:(NTBasicRequest *)basic
                          andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock
{
    [self basicRequestWithRequest:basic
            downloadProgressBlock:nil
              uploadProgressBlock:nil
                      andEndBlock:endRequestBlock];
}

//统一调用的请求
-(void)basicRequestWithRequest:(NTBasicRequest *)basic
         downloadProgressBlock:(DownloadProgressBlock )downloadBlock
           uploadProgressBlock:(DownloadProgressBlock)uploadBlock
                   andEndBlock:(void(^)(id responseData,NSError * error))endBlock
{
    if (!basic.requestid||[basic.requestid intValue]<=0)
    {
        return;
    }
    
    NSString * tagId = basic.requestid;
    [basic setValue:tagId forKey:@"rd"];
    NSString * url = basic.requestUrlStr;
    
    NSDictionary * dataDic = [basic currentDataDic];
    if (basic.needAuthorization)
    {
        //针对认证的特殊处理
        NSString * name = [dataDic valueForKey:@"name"];
        NSString * pass = [dataDic valueForKey:@"pass"];
        
        if (!name) {
            name=@"";
        }
        if (!pass) {
            pass=@"";
        }
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:name password:pass];
        NSMutableDictionary * postDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
        //        [postDic removeObjectForKey:@"name"];
        //        [postDic removeObjectForKey:@"pass"];
        dataDic = postDic;
    }else{
        [manager.requestSerializer clearAuthorizationHeader];
    }
    

    NSString * paragramStr = [dataDic JSONString];
    NSLog(@"start sepcial RequestUrl:%@ paragram:%@",url,paragramStr);
//    __weak NTConnectClient * weakClient = self;
    AFHTTPRequestOperation * requestOperation = [manager  GET:url
                                                    parameters:dataDic
                                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
                                                           id valueData = [NTConnectSepcialClient checkResponseDataWithJSONKitAndCustomReplace:responseObject];
        NSString * str = nil;
//        [valueData JSONString];
        str = valueData;
                                                           NSLog(@"End RequestUrl:%@ response data:%@",paragramStr,[str length]>100?[str substringToIndex:100]:str);
                                                           endBlock(responseObject,nil);
                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           NSLog(@"End RequestUrl:%@ response error:%@",paragramStr,error);
                                                           endBlock(nil,error);
                                                       }];
    
    
    [requestOperation setUploadProgressBlock:uploadBlock];
    [requestOperation setDownloadProgressBlock:downloadBlock];
    
}
+(id)checkResponseDataWithJSONKitAndCustomReplace:(id)responseObject
{
    NSString * str = nil;
    if (responseObject&&[responseObject isKindOfClass:[NSData class]]&&[responseObject length]>0) {
        str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    }else if([responseObject isKindOfClass:[NSString class]]){
        str = responseObject;
    }
    
    if (!str) {
        return responseObject;
    }
    
    NSString * compare = @"jsonpCallback(";
    NSString * last = @")";
    if ([str hasPrefix:compare]) {
        str = [str substringFromIndex:[compare length]];
    }
    if ([str hasSuffix:last]) {
        str = [str substringToIndex:[str length]-[last length]];
    }
    responseObject = [str objectFromJSONString];
    return responseObject;
}



@end
