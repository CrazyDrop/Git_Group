//
//  ZAOAFHTTPRequestOperationManager.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequestOperationManager.h"
#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestKernel.h"
#import "ZAIWebRequestGeneralParameter.h"
#import "ZAIPostNotificationOnMainThread.h"

@implementation ZAIWebRequestOperationManager

static NSArray *methodStrings;

+ (instancetype)sharedClient
{
    static ZAIWebRequestOperationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [ZAIWebRequestOperationManager new];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        methodStrings = @[@"GET",@"POST",@"PUT",@"PATCH",@"DELETE"];
        
    });
    
    return _sharedClient;
}

-(void)cancelWithTask:(ZAIWebRequestTask *)task
{
    [((AFHTTPRequestOperation *)task.request) cancel];
}

-(void)setHeadValueForRequestWithTask:(ZAIWebRequestTask *)api
{
    NSString *token = @"abc";//[[AccountManager sharedInstance] account].token
    if(token)
    {
        [self.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    NSString *deviceID = [ZAIWebRequestGeneralParameter currentDeviceIdentifer];
    
    [self.requestSerializer setValue: [[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"osVersion"];
    
    [self.requestSerializer setValue:[ZAIWebRequestGeneralParameter platformString] forHTTPHeaderField:@"osDevice"];
    
    [self.requestSerializer setValue:deviceID forHTTPHeaderField:@"deviceId"];
    
    if(api.sign)
        [self.requestSerializer setValue:api.sign forHTTPHeaderField:@"sign"];
    
    [self.requestSerializer setValue:[ZAIWebRequestGeneralParameter currentAppBundleShortVersion] forHTTPHeaderField:@"v"];
    
    [self.requestSerializer setValue:@"IOS" forHTTPHeaderField:@"t"];
}

-(NSString *)methodStringWithMethodType:(ZAIWebRequestMethod)type
{
    if(type >= ZAOWebRequestMethodMAX)
        type = ZAOWebRequestMethodGET;
    
    return [methodStrings objectAtIndex:type];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    return [self HTTPRequestOperationWithRequest:request success:success failure:failure];
}

-(void)startRequestWithTask:(ZAIWebRequestTask *)task
{
    [self setHeadValueForRequestWithTask:task];
    
    __block AFHTTPRequestOperation *request = [self HTTPRequestOperationWithHTTPMethod:[self methodStringWithMethodType:task.requestMethod] URLString:task.requestUrl parameters:task.parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *returnDics =@{@"returnCode":@"successed", @"data":responseObject, @"task":request, @"userInput":!task.kernel.userInput ?[NSNull null]:task.kernel.userInput};
        
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

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
    
    task.request = request;
    [self.operationQueue addOperation:request];
}

@end
