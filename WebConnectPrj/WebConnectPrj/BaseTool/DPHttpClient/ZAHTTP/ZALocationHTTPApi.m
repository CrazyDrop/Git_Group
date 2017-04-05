//
//  ZALocationHTTPApi.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/23.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationHTTPApi.h"
#import "NSObject+AutoCoding.h"
@implementation ZALocationHTTPRequest
@end

@implementation ZALocationHTTPResponse
@end

@interface ZALocationHTTPApi()
//未能共用STIHTTPSessionManager网络请求中心
@property (nonatomic,strong) STIHTTPSessionManager * sessionManager;

@end
@implementation ZALocationHTTPApi
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZALocationHTTPRequest alloc] initWithEndpoint:@"" method:STIHTTPRequestMethodGet];
        self.req.responseClass = [ZALocationHTTPResponse class];
    }
    return self;
}

-(STIHTTPSessionManager *)sessionManager
{
    if(!_sessionManager)
    {
        //        ?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0&location=39.983424,116.322987
        NSString * locationUrl = @"https://api.map.baidu.com/geocoder/v2/";
        
        STIHTTPSessionManager * client = [[STIHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:locationUrl]];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager = client;
    }
    return _sessionManager;
}

-(instancetype)shareLocationAPI
{
    static ZALocationHTTPApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
//        //        &location=39.983424,116.322987
//        NSString * locationUrl = @"https://api.map.baidu.com/geocoder/v2/?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0";
//        
//        _sharedClient = [[STIHTTPRequestManager alloc] initWithBaseURL:[NSURL URLWithString:locationUrl]];
//        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
//        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient = [[ZALocationHTTPApi alloc] init];
    });
    return _sharedClient;
}

-(void)send
{
    if ( self.sessionManager.setup )
    {
        self.sessionManager.setup(nil);
    }
    
    //        ?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0&location=39.983424,116.322987

    AFHTTPRequestSerializer * requestSlizer = self.sessionManager.requestSerializer;
    requestSlizer.timeoutInterval = 5;
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    [parameters addEntriesFromDictionary:self.req.parameters];
    [parameters setValue:@"petGKNAWHdahKOlzqPcghijZ" forKey:@"ak"];
    [parameters setValue:@"renderReverse" forKey:@"callback"];
    [parameters setValue:@"json" forKey:@"output"];
    [parameters setValue:@"0" forKey:@"pois"];
    [parameters setValue:@"wgs84ll" forKey:@"coordtype"];
    
    
    [self.sessionManager method:STIHTTPRequestMethodGet
                           endpoint:self.req.endpoint
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                //                                __strong typeof(weakSelf) self = weakSelf;
                                NSString * resultStr = nil;
                                if(responseObject && [responseObject length]>0)
                                {
                                   resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                    
                                    if(!resultStr)
                                    {
                                        resultStr = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];

                                    }
                                    
                                    NSString * tagStr = @"renderReverse&&renderReverse(";
                                    resultStr = [resultStr stringByReplacingOccurrencesOfString:tagStr withString:@""];
                                    if([resultStr hasSuffix:@")"])
                                    {
                                        resultStr = [resultStr substringToIndex:[resultStr length]-1];
                                    }
                                    
                                    responseObject = [resultStr JSONDecoded];
                                }
                                
                                
                                self.resp = [self.req.responseClass ac_objectWithAny:[self processedDataWithResponseObject:responseObject task:task]];

                                self.responseObject = responseObject;
                                if ( self.whenUpdate ) {
                                    self.whenUpdate( self.resp, nil );
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                                
                                [self.sessionManager handleError:error responseObject:responseObject task:task failureBlock:self.whenUpdate];
                            }];

}

-(void)cancel
{
    NSURLSession * httpSession = self.sessionManager.session;
    [httpSession invalidateAndCancel];
}



@end
