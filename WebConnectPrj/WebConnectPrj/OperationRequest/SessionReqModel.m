//
//  SessionReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "SessionReqModel.h"
#import "VPNProxyModel.h"
@interface SessionReqModel()
@property (nonatomic, strong) NSDictionary * proxyDic;
@property (nonatomic, strong) NSURLSession * session;

@end
@implementation SessionReqModel

+ (NSOperationQueue *)zw_sharedDetailJsonRequestOperationQueue
{
    static NSOperationQueue *_zw_sharedDetailJsonRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zw_sharedDetailJsonRequestOperationQueue = [[NSOperationQueue alloc] init];
        _zw_sharedDetailJsonRequestOperationQueue.maxConcurrentOperationCount = 50;
    });
    
    return _zw_sharedDetailJsonRequestOperationQueue;
}


-(id)initWithProxyModel:(VPNProxyModel *)model
{
    self = [super init];
    if(self)
    {
        self.proxyModel = model;
        self.proxyDic = model.detailProxyDic;
    }
    return self;
}
-(NSURLSession *)session
{
    if(!_session)
    {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        config.connectionProxyDictionary = self.proxyDic;
        config.timeoutIntervalForRequest = 5;
    
        NSOperationQueue * jsonQueue = [[self class] zw_sharedDetailJsonRequestOperationQueue];
        NSURLSession *aSession = [NSURLSession sessionWithConfiguration:config
                                                              delegate:nil
                                                         delegateQueue:jsonQueue];
        _session = aSession;
    }
    return _session;
}



@end
