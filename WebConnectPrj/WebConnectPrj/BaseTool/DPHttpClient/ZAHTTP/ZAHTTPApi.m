//
//  ZAHTTPApi.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
#import "NSObject+AutoCoding.h"
#import "SFHFKeychainUtils.h"
#import "DZUtils.h"

#define UseURLSessionTask [NSURLSession class] != nil

@implementation ZAHTTPApi

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.timeoutInterval = 10;
    }
    return self;
}

- (NSMutableDictionary *)createFakeData:(STIHTTPRequest *)req
{
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] init];
    retDict[@"resultCode"] = @0;
    retDict[@"message"] = @"ok";
    ZAHTTPRequest *request = (ZAHTTPRequest *)req;
    NSString *serviceName = NSStringFromClass([request class]);
//    if([serviceName isEqualToString:NSStringFromClass([RegisterRequest class])])
    {
        retDict[@"token"] = @"DL7F856R4FZI1Q3MX8P1HLJ7PWO8Q63X";
        retDict[@"userId"] = @"123456";
        retDict[@"acctInfoComplete"] = @0;
    }
//    else if([serviceName isEqualToString:NSStringFromClass([LoginRequest class])])
    {
        retDict[@"token"] = @"DL7F856R4FZI1Q3MX8P1HLJ7PWO8Q63X";
        retDict[@"userId"] = @"123456";
    }
//    else if([serviceName isEqualToString:NSStringFromClass([ThirdPartyRegisterReqeust class])])
    {
        retDict[@"token"] = @"DL7F856R4FZI1Q3MX8P1HLJ7PWO8Q63X";
        retDict[@"userId"] = @"123456";
    }
//    else if([serviceName isEqualToString:NSStringFromClass([ThirdPartyLoginRequest class])])
    {
        retDict[@"token"] = @"DL7F856R4FZI1Q3MX8P1HLJ7PWO8Q63X";
        retDict[@"userId"] = @"123456";
        retDict[@"isRegister"] = @0;
        retDict[@"acctInfoComplete"] = @0;
    }
    return retDict;
}

- (void)send
{
    
    NSString * token = nil;

    if(token)
    {
        if(self.HTTPRequestManager)
            [self.HTTPRequestManager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
        else if(self.HTTPSessionManager)
            [self.HTTPSessionManager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
    }
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *platform = [DZUtils platformString];
    NSString *deviceId = [DZUtils currentDeviceIdentifer];
    NSString *deviceIdCheck = [SFHFKeychainUtils commonStaticAppDeviceId];
    
    NSString *sign = [(ZAHTTPRequest *)self.req createSign];
    NSString *version = [DZUtils currentAppBundleShortVersion];
    NSString *type = @"4";
    
    AFHTTPRequestSerializer * requestSlizer = self.HTTPRequestManager.requestSerializer;
    if(!requestSlizer) requestSlizer = self.HTTPSessionManager.requestSerializer;
    
    if(sign)
    {
        [requestSlizer setValue:sign forHTTPHeaderField:@"sign"];
    }

    [requestSlizer setValue:version forHTTPHeaderField:@"Client-Version"];
    [requestSlizer setValue:type forHTTPHeaderField:@"Client-Type"];
    [requestSlizer setValue:deviceId forHTTPHeaderField:@"Device-ID"];
    
    [requestSlizer setValue:osVersion forHTTPHeaderField:@"OS-Version"];
    [requestSlizer setValue:platform forHTTPHeaderField:@"Device-Type"];

    [requestSlizer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSlizer setValue:@"application/json; charset=utf8" forHTTPHeaderField:@"Content-Type"];
    requestSlizer.timeoutInterval = self.timeoutInterval;

    
#ifdef FakeData
    [self.HTTPSessionManager method:self.req.method
                           endpoint:self.req.endpoint
                         parameters:self.req.parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                self.resp = [self.req.responseClass ac_objectWithAny:[self createFakeData:self.req]];
                                
                                if ( self.whenUpdate ) {
                                    self.whenUpdate( self.resp, nil );
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                                self.resp = [self.req.responseClass ac_objectWithAny:[self createFakeData:self.req]];
                                
                                if ( self.whenUpdate ) {
                                    self.whenUpdate( self.resp, nil );
                                }
                            }];
    
//    [self.HTTPRequestManager method:self.req.method
//                           endpoint:self.req.endpoint
//                         parameters:self.req.parameters
//                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                
//                                self.resp = [self.req.responseClass ac_objectWithAny:[self createFakeData:self.req]];
//                                
//                                if ( self.whenUpdate ) {
//                                    self.whenUpdate( self.resp, nil );
//                                }
//                            } failure:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
//                                self.resp = [self.req.responseClass ac_objectWithAny:[self createFakeData:self.req]];
//                                
//                                if ( self.whenUpdate ) {
//                                    self.whenUpdate( self.resp, nil );
//                                }
//                            }];
#else
    
    if(UseURLSessionTask)
    {
        if ( self.HTTPSessionManager.setup ) {
            self.HTTPSessionManager.setup(nil);
        }
        [self.HTTPSessionManager method:self.req.method
                               endpoint:self.req.endpoint
                             parameters:self.req.parameters
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    //                                __strong typeof(weakSelf) self = weakSelf;
                                    self.resp = [self.req.responseClass ac_objectWithAny:[self processedDataWithResponseObject:responseObject task:task]];

                                    self.responseObject = responseObject;
                                    if ( self.whenUpdate ) {
                                        self.whenUpdate( self.resp, nil );
                                    }
                                }
                                failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                                    [self.HTTPSessionManager handleError:error responseObject:responseObject task:task failureBlock:self.whenUpdate];
                                }];
    }else{
        [self.HTTPRequestManager method:self.req.method
                               endpoint:self.req.endpoint
                             parameters:self.req.parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    self.resp = [self.req.responseClass ac_objectWithAny:[self processedDataWithResponseObject:responseObject operation:operation]];
                                    self.responseObject = responseObject;
                                    if(self.whenUpdate)
                                    {
                                        self.whenUpdate(self.resp, nil);
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                    [self.HTTPRequestManager handleError:error responseObject:responseObject operation:operation failureBlock:self.whenUpdate];
                                }];
        
        
    }
#endif
    
    NSLog(@"deviceId:%@ deviceIdCheck:%@ web Parameter:%@ token:%@",deviceId,deviceIdCheck,self.req.parameters,token);

}

- (NSMutableDictionary *)getReturnDataFromResponse:(id)responseObject
{
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] init];
    
    if([responseObject isKindOfClass:[NSDictionary class]])
    {
        if([responseObject objectForKey:@"returnCode"])
        {
//            if([[responseObject objectForKey:@"returnCode"] intValue] == HTTPReturnTokenExpire)//Token验证失败
            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:TokenExpiredNotification object:nil];
            }
        }
        
        for (NSString *key in [responseObject allKeys]) {
            [retDict setObject:responseObject[key] forKey:key];
        }
    }
    return retDict;
}

- (id)processedDataWithResponseObject:(id)responseObject operation:(AFHTTPRequestOperation *)operation
{
    return [self getReturnDataFromResponse:responseObject];
}

- (id)processedDataWithResponseObject:(id)responseObject task:(NSURLSessionDataTask *)task
{
    return [self getReturnDataFromResponse:responseObject];
}

@end
