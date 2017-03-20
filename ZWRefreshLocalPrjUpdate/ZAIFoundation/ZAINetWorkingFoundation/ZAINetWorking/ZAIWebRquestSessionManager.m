//
//  ZAOHTTPSessionManager.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/12.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRquestSessionManager.h"
#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestKernel.h"
#import "ZAIPostNotificationOnMainThread.h"
#import "ZAIUrlForRequest.h"
#import "ZAIWebRequestGeneralParameter.h"

static NSArray *methodStrings;

@implementation ZAIWebRquestSessionManager

+ (instancetype)sharedClient
{
    static ZAIWebRquestSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ZAIWebRquestSessionManager alloc] init];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        methodStrings = @[@"GET",@"POST",@"PUT",@"PATCH",@"DELETE"];

    });
    
    return _sharedClient;
}

-(void)cancelWithTask:(ZAIWebRequestTask *)task
{
    [((NSURLSessionDataTask *)task.request) cancel];
}

-(NSString *)methodStringWithMethodType:(ZAIWebRequestMethod)type
{
    if(type >= ZAOWebRequestMethodMAX)
        type = ZAOWebRequestMethodGET;
    
    return [methodStrings objectAtIndex:type];
}

-(void)startRequestWithTask:(ZAIWebRequestTask *)task
{
    [self setHeadValueForRequestWithTask:task];
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:[self methodStringWithMethodType:task.requestMethod] URLString:task.requestUrl
       parameters:task.parameters success:^(NSURLSessionDataTask *secssionDataTask, id responseObj)
    {
        NSDictionary *returnDics =@{@"returnCode":@"successed", @"data":responseObj, @"task":secssionDataTask, @"userInput":!task.kernel.userInput ?[NSNull null]:task.kernel.userInput};
        
        if(task.kernel.apiOutputType == ZAOApiOutputTypeBlock && task.kernel.apiBlockOutputHandler)
        {
            task.kernel.apiBlockOutputHandler(returnDics);
        }
        else if(task.kernel.apiOutputType == ZAOApiOutputTypeNotification && [task.kernel.apiNotificationName length])
        {
            NSNotification *notification = [NSNotification notificationWithName:task.kernel.apiNotificationName
                                                                         object:returnDics];
            
            [ZAIPostNotificationOnMainThread postNotification:notification];
        }
    }
    failure:^(NSURLSessionDataTask *secssionDataTask, NSError *error)
    {
        NSDictionary *returnDics =@{@"returnCode":@"failed", @"error":error,@"userInput":!task.kernel.userInput ?[NSNull null]:task.kernel.userInput};
        
        if(task.kernel.apiOutputType == ZAOApiOutputTypeBlock && task.kernel.apiBlockOutputHandler)
        {
            task.kernel.apiBlockOutputHandler(returnDics);
        }
        else if(task.kernel.apiOutputType == ZAOApiOutputTypeNotification && [task.kernel.apiNotificationName length])
        {
            NSNotification *notification = [NSNotification notificationWithName:task.kernel.apiNotificationName
                                                                         object:returnDics];
            
            [ZAIPostNotificationOnMainThread postNotification:notification];
        }
    }];
    task.request = dataTask;
    
    [dataTask resume];
}
-(void)setHeadValueForRequestWithTask:(ZAIWebRequestTask *)task
{
    NSString *token = @"abc";//[[AccountManager sharedInstance] account].token
    if(token)
    {
        [self.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    [self.requestSerializer setValue: [[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"osVersion"];
    
    [self.requestSerializer setValue:[ZAIWebRequestGeneralParameter platformString] forHTTPHeaderField:@"osDevice"];
    
    [self.requestSerializer setValue:[ZAIWebRequestGeneralParameter currentDeviceIdentifer] forHTTPHeaderField:@"deviceId"];
    
    if(task.sign)
    [self.requestSerializer setValue:task.sign forHTTPHeaderField:@"sign"];
    
    [self.requestSerializer setValue:[ZAIWebRequestGeneralParameter currentAppBundleShortVersion] forHTTPHeaderField:@"v"];
    
    [self.requestSerializer setValue:@"IOS" forHTTPHeaderField:@"t"];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;

    NSString *str = [[NSURL URLWithString:URLString] absoluteString];

    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:str parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu" a
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    return dataTask;
}

@end
