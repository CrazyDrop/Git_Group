//
//  ZAORequestWebData.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequestAPI.h"
#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestService.h"
#import "ZAIWebRequestKernel.h"

@implementation ZAIWebRequestAPI

+ (void) cancelRequest:(ZAIRequestID)requestId
{
    [[ZAIWebRequestService shareService] cancelAPI:requestId];
}

+ (ZAIRequestID)requestWebDataWithTask:(ZAIWebRequestTask*)task;
{
    return [[ZAIWebRequestService shareService] requestApiAsynchronous:task];
}

+ (ZAIRequestID)requestWebDatawithBlock:(outputHandler)outputBlock method:(ZAIWebRequestMethod)methodType url:(NSString *)urlString parameters:(NSDictionary*)parameters APIInput:(NSDictionary *)input;
{
    ZAIWebRequestKernel *kernel = [ZAIWebRequestKernel new];
    kernel.apiBlockOutputHandler = outputBlock;
    kernel.userInput = input;
    kernel.apiOutputType = ZAOApiOutputTypeBlock;
    
    ZAIWebRequestTask *task = [ZAIWebRequestTask new];
    task.requestUrl = urlString;
    task.parameters = parameters;
    task.requestMethod = methodType;
    
    task.kernel =kernel;
    
    return [[ZAIWebRequestService shareService] requestApiAsynchronous:task];
}

+ (ZAIRequestID)requestWebDataWithNotification:(NSString *)message method:(ZAIWebRequestMethod)methodType url:(NSString *)urlString  parameters:(NSDictionary*)parameters APIInput:(NSDictionary *)input
{
    ZAIWebRequestKernel *kernel = [ZAIWebRequestKernel new];
    kernel.apiNotificationName = message;
    kernel.userInput = input;
    kernel.apiOutputType = ZAOApiOutputTypeNotification;
    
    ZAIWebRequestTask *task = [ZAIWebRequestTask new];
    task.requestUrl = urlString;
    task.parameters = parameters;
    task.requestMethod = methodType;
    
    task.kernel = kernel;
    
    return [[ZAIWebRequestService shareService] requestApiAsynchronous:task];
}
@end
