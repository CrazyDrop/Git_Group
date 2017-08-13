//
//  ZWSessionReqOperation.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWSessionReqOperation.h"
#import "JSONKit.h"

@interface ZWSessionReqOperation()
{
    BOOL executing;
    BOOL finished;
    NSOperationQueue * queue;
}
@property (nonatomic, strong)  NSCondition *  lockCondition;
@property (nonatomic, strong)  NSURLSessionTask * sessionTask;
@end


@implementation ZWSessionReqOperation

- (id)init {
    if(self = [super init])
    {
        executing = NO;
        finished = NO;
        self.lockCondition = [[NSCondition alloc] init];
    }
    return self;
}
- (void)cancel
{
    self.dataDelegate = nil;
    [self.sessionTask cancel];
}
- (BOOL)isConcurrent {
    
    return YES;
}
- (BOOL)isExecuting {
    
    return executing;
}
- (BOOL)isFinished {
    
    return finished;
}

- (void)start
{
    //第一步就要检测是否被取消了，如果取消了，要实现相应的KVO
    if ([self isCancelled]) {
        
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    
    //如果没被取消，开始执行任务
    [self willChangeValueForKey:@"isExecuting"];
    
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main
{
    @try {
        
        @autoreleasepool
        {
            //在这里定义自己的并发任务
            //进行网络请求、数据解析、数据回传
            NSString * urlStr = self.reqUrl;
            NSURL * url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
            
            
            NSString * str = @"xyqcbg2/2.2.8 CFNetwork/758.1.6 Darwin/15.0.0";
            [request setValue:str forHTTPHeaderField:@"User-Agent"];
            
            NSDictionary * cookie = _cookieDic;
            if(cookie)
            {
                [request setValue: [cookie objectForKey:@"Cookie"] forHTTPHeaderField: @"Cookie"];
            }
            
            __weak typeof(self) weakSelf = self;
            void(^finishBlock)(NSData * data ,NSURLResponse * response ,NSError * error) = ^void(NSData * responseObject ,NSURLResponse * response ,NSError * error)
            {
                
                if(weakSelf.saveCookie)
                {
                    if([response respondsToSelector:@selector(allHeaderFields)] && [weakSelf.dataDelegate respondsToSelector:@selector(sessionRequestOperation:doneWebRequestBackHeaderDic:andStartUrl:)])
                    {
                        NSDictionary *fields = ((NSHTTPURLResponse*)response).allHeaderFields;
                        [weakSelf.dataDelegate sessionRequestOperation:self doneWebRequestBackHeaderDic:fields andStartUrl:urlStr];
                    }
                }
                
                NSDictionary * dic = nil;
                if(!error)
                {
                    NSString * resultStr = nil;
                    if(responseObject && [responseObject length]>0)
                    {
                        resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        
                        if(!resultStr)
                        {
                            resultStr = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                            
                        }
                        
                        if(!resultStr || [resultStr containsString:@"action"]|| [resultStr hasPrefix:@"<!DOCTYPE html PUBLIC"])
                        {
                            unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                            resultStr = [[NSString alloc] initWithData:responseObject encoding:encode];
                            if([resultStr hasPrefix:@"出错"])
                            {
                                NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:resultStr,@"msg", nil];
                                resultStr = [dic JSONString];
                            }
                        }
                        
                        if([resultStr hasPrefix:@"<!DOCTYPE html PUBLIC"])
                        {
                            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:resultStr,@"html", nil];
                            resultStr = [dic JSONString];
                        }

                    }
                    
                    dic = [resultStr objectFromJSONString];
                }else
                {
                    dic = @{@"webError":error};
                }
                
                if(!dic)
                {
                    dic = @{@"noneError":@"none"};
                }
                
                if ([weakSelf.dataDelegate respondsToSelector:@selector(sessionRequestOperation:finishReq:errorDic:)])
                {
                    [weakSelf.dataDelegate sessionRequestOperation:self
                                                     finishReq:dic
                                                      errorDic:nil];
                }

                [weakSelf.lockCondition lock];
                [weakSelf.lockCondition signal];
                [weakSelf.lockCondition unlock];
            };
            
            NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
            config.connectionProxyDictionary = self.proxyDic;
            if(self.timeOutNum > 0){
                config.timeoutIntervalForRequest = self.timeOutNum;
            }
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                                  delegate:nil
                                                             delegateQueue:nil];
            
            
            NSURLSessionTask *task = [session dataTaskWithRequest:request
                                                completionHandler:finishBlock];
            self.sessionTask = task;
            
            // 启动任务
            [task resume];
            [self.lockCondition lock];
            [self.lockCondition wait];
            [self.lockCondition unlock];
            
//            NSThread *thread = [NSThread currentThread];
//            NSLog(@"%@",thread);
            
            //任务执行完成后要实现相应的KVO
            [self willChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
            
            executing = NO;
            finished = YES;
            
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s %@",__FUNCTION__,exception);
    }
}


@end
