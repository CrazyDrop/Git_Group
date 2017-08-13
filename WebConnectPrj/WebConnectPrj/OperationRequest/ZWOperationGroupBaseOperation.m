//
//  ZWOperationGroupBaseOperation.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/13.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWOperationGroupBaseOperation.h"
#import "SessionReqModel.h"
#import "JSONKit.h"
@interface ZWOperationGroupBaseOperation()
{
    BOOL executing;
    BOOL finished;
    NSOperationQueue * subQueue;
//    NSThread * operationThread;
//    NSOperationQueue * jsonQueue;
}
@property (nonatomic, strong) NSMutableArray * resultArr;
@property (nonatomic, strong) NSArray * sessionArr;
@property (nonatomic, strong) NSString * resultTag;

@property (nonatomic, strong) NSCondition * lockCondition;
@end

@implementation ZWOperationGroupBaseOperation
- (id)init {
    if(self = [super init])
    {
        executing = NO;
        finished = NO;
        
        self.resultTag = @"tag";
        self.lockCondition = [[NSCondition alloc] init];
        
        subQueue = [[NSOperationQueue alloc] init];
        subQueue.maxConcurrentOperationCount = 30;
        subQueue.name = @"group-operation-queue";
        
        [self addObserver:self forKeyPath:@"resultFinish" options:NSKeyValueObservingOptionNew context:NULL];

    }
    return self;
}
-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"resultFinish"];
}

-(void)setMaxOperationNum:(NSInteger)maxOperationNum
{
    _maxOperationNum = maxOperationNum;
    subQueue.maxConcurrentOperationCount = maxOperationNum;
}
-(void)cancel
{
    [subQueue cancelAllOperations];
    
    // 取消队列的挂起状态(只要是取消了队列的操作，我们就把队列处于一个启动状态，以便于后续的开始)
    subQueue.suspended = NO;
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
    
    NSArray * array = self.reqModels;
    
    if(!array && self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(groupBaseRequestOperationCreateReqModels:)])
    {
        array = [self.dataDelegate groupBaseRequestOperationCreateReqModels:self];
        self.reqModels = array;
    }
    
    NSMutableArray * result = [NSMutableArray array];
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        NSString * tagStr = self.resultTag;
        [result addObject:tagStr];
    }
    self.resultArr = result;
    
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
            //进行operation创建，调用
            
            NSArray * array = self.reqModels;
            if(array && [array count] > 0)
            {
                for (NSInteger index = 0;index < [array count] ;index ++ )
                {
                    SessionReqModel * req = [array objectAtIndex:index];
                    [self startWebRequestWithDetailReqSession:req];
                }
                
                [self.lockCondition lock];
                [self.lockCondition wait];
                [self.lockCondition unlock];
            }
            
            if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(groupBaseRequestOperation:finishReq:errorDic:)])
            {
                [self.dataDelegate groupBaseRequestOperation:self
                                                   finishReq:self.resultArr
                                                    errorDic:nil];
            }
            
            [self finishDetailWebRequestWithTotalFinished];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s %@",__FUNCTION__,exception);
    }
}

-(void)finishDetailWebRequestWithTotalFinished
{
    //    NSThread *thread = [NSThread currentThread];
    //    NSLog(@"%@",thread);
    
    //任务执行完成后要实现相应的KVO
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}
-(NSInteger)unFinishedReqestNumber
{
    NSInteger countNum = 0;
    NSString * tag = self.resultTag;
    NSArray * arr = self.resultArr;
    for (NSInteger index = 0;index < [arr count] ;index++ )
    {
        NSString * eve = [arr objectAtIndex:index];
        if([eve isKindOfClass:[NSString class]] && [tag isEqualToString:eve]){
            countNum ++;
        }
    }
    return countNum;
}
-(void)startWebRequestWithDetailReqSession:(SessionReqModel *)reqModel
{
    //在这里定义自己的并发任务
    //进行网络请求、数据解析、数据回传
    NSString * urlStr = reqModel.url;
    NSDictionary * cookie = reqModel.cookieDic;
    NSDictionary * proxyDic = reqModel.proxyDic;
    NSURL * url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    
    NSString * str = @"xyqcbg2/2.2.8 CFNetwork/758.1.6 Darwin/15.0.0";
    [request setValue:str forHTTPHeaderField:@"User-Agent"];
    
    if(cookie)
    {
        [request setValue: [cookie objectForKey:@"Cookie"] forHTTPHeaderField: @"Cookie"];
    }
    
    __weak typeof(self) weakSelf = self;
    void(^finishBlock)(NSData * data ,NSURLResponse * response ,NSError * error) = ^void(NSData * responseObject ,NSURLResponse * response ,NSError * error)
    {
        
        if(weakSelf.saveCookie && [weakSelf.dataDelegate respondsToSelector:@selector(groupBaseRequestOperation:doneWebRequestBackHeaderDic:andStartUrl:)])
        {
            NSDictionary *fields = ((NSHTTPURLResponse*)response).allHeaderFields;
            [weakSelf.dataDelegate groupBaseRequestOperation:self
                                 doneWebRequestBackHeaderDic:fields
                                                 andStartUrl:urlStr];
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
        
        NSArray * subArr = nil;
        if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(groupBaseRequestOperation:finishEveReq:sessionModel:)])
        {
            subArr = [self.dataDelegate groupBaseRequestOperation:self
                                            finishEveReq:dic
                                             sessionModel:reqModel];
        }
        
        if(!subArr) subArr = [NSArray array];
        NSInteger index = [weakSelf.reqModels indexOfObject:reqModel];

        [weakSelf finishGroupRequestWithIndex:index
                                  andSubArray:subArr];
    };
    
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    config.connectionProxyDictionary = proxyDic;
    if(self.timeOutNum > 0)
    {
        config.timeoutIntervalForRequest = self.timeOutNum;
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:finishBlock];
    
    // 启动任务
    [task resume];
}

-(void)finishGroupRequestWithIndex:(NSInteger)index andSubArray:(NSArray * )array
{
    @synchronized (self.resultArr)
    {
        [self.resultArr replaceObjectAtIndex:index withObject:array];
        NSInteger limitNum = [self unFinishedReqestNumber];
        if(limitNum == 0)
        {
            [self.lockCondition lock];
            [self.lockCondition signal];
            [self.lockCondition unlock];
        }
    }
}



@end
