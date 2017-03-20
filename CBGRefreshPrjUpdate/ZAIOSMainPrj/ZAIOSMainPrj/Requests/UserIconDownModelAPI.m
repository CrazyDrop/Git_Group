//
//  UserIconDownModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/10.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "UserIconDownModelAPI.h"
#import "SFHFKeychainUtils.h"
#import "NSObject+AutoCoding.h"


@implementation UserIconDownModelRequest
@end

@implementation UserIconDownModelResponse
@end

@interface UserIconDownModelAPI()
@property (nonatomic,strong) STIHTTPSessionManager * sessionManager;
@end

@implementation UserIconDownModelAPI

@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[UserIconDownModelRequest alloc] initWithEndpoint:@"papa/user/downloadIcon" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [UserIconDownModelResponse class];
    }
    return self;
}

-(STIHTTPSessionManager *)sessionManager
{
    if(!_sessionManager)
    {
        
        STIHTTPSessionManager * client = [[STIHTTPSessionManager alloc] initWithBaseURL:self.HTTPSessionManager.baseURL];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager = client;
    }
    return _sessionManager;
}


-(void)send
{
    NSString * token = [DZUtils currentLoginToken];
    
    if(token)
    {
        [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
    }
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *platform = [DZUtils platformString];
    NSString *deviceId = [DZUtils currentDeviceIdentifer];
    NSString *deviceIdCheck = [SFHFKeychainUtils commonStaticAppDeviceId];
    
    NSString *sign = [(ZAHTTPRequest *)self.req createSign];
    NSString *version = [DZUtils currentAppBundleShortVersion];
    NSString *type = @"4";
    
    AFHTTPRequestSerializer * requestSlizer = self.sessionManager.requestSerializer;
    
    if(sign)
    {
        [requestSlizer setValue:sign forHTTPHeaderField:@"sign"];
    }
    
    [requestSlizer setValue:version forHTTPHeaderField:@"Client-Version"];
    [requestSlizer setValue:type forHTTPHeaderField:@"Client-Type"];
    [requestSlizer setValue:deviceId forHTTPHeaderField:@"Device-ID"];
    
    [requestSlizer setValue:osVersion forHTTPHeaderField:@"OS-Version"];
    [requestSlizer setValue:platform forHTTPHeaderField:@"Device-Type"];
    
    requestSlizer.timeoutInterval = self.timeoutInterval;
    

    
    
    [self.sessionManager method:STIHTTPRequestMethodGet
                       endpoint:self.req.endpoint
                     parameters:self.req.parameters
                        success:^(NSURLSessionDataTask *task, id responseObject) {
                            
                            self.responseObject = responseObject;
                            if ( self.whenUpdate ) {
                                self.whenUpdate( self.resp, nil );
                            }
                        }
                        failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                            
                            [self.sessionManager handleError:error responseObject:responseObject task:task failureBlock:self.whenUpdate];
                        }];
    
    NSLog(@"deviceId:%@ deviceIdCheck:%@ web Parameter:%@ token:%@",deviceId,deviceIdCheck,self.req.parameters,token);

}


-(void)cancel
{
    NSURLSession * httpSession = self.sessionManager.session;
    [httpSession invalidateAndCancel];
}


@end
