//
//  ZAOWebAPIRequestService.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//
#import "ZAIWebRequestKernel.h"
#import "ZAIWebRequestService.h"
#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestManager.h"
#import "ZAIOSVERSION.h"

static ZAIWebRequestService *sharedInstance = nil;

@interface ZAIWebRequestService()

@property(nonatomic, copy)ZAIWebRequestCollector* requestCollector;

@end

@implementation ZAIWebRequestService

+ (ZAIWebRequestService *)shareService
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [ZAIWebRequestService new];
        }
        return sharedInstance;
    }
}

- (id) init
{
    if (self = [super init])
    {
        _requestCollector = [ZAIWebRequestCollector new];
    }
    
    return self;
}

-(ZAIRequestID)requestApiAsynchronous:(ZAIWebRequestTask *)task
{
    if(!task)return ZAORequestInvalidID;
    
    return [self proceedRequestWithTask:task];
}
                             

- (void) cancelAPI : (ZAIRequestID) apiUID
{
    [self.requestCollector removeRequestWithUid:apiUID];
}

#pragma mark - proceed api

- (ZAIRequestID) proceedRequestWithTask : (ZAIWebRequestTask *) task
{
    ZAIRequestID uid = ZAORequestInvalidID;
    
    if(task.kernel.apiOutputType == ZAOApiOutputTypeBlock || task.kernel.apiOutputType == ZAOApiOutputTypeNotification)
    {
        uid = [self.requestCollector insertRequest:task];
        [[ZAIWebRequestManager shareClient] startRequestWithTask:task];
    }
    return uid;
}


@end
