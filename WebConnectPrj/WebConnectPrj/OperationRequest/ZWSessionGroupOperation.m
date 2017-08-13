//
//  ZWSessionGroupOperation.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWSessionGroupOperation.h"
#import "ZWSessionReqOperation.h"
#import "SessionReqModel.h"
@interface ZWSessionGroupOperation()<ZWSessionReqDelegate>
{
    BOOL executing;
    BOOL finished;
    NSOperationQueue * subQueue;
}
@property (nonatomic, strong) NSMutableArray * resultArr;
@property (nonatomic, strong) NSArray * sessionArr;
@end

@implementation ZWSessionGroupOperation
- (id)init {
    if(self = [super init])
    {
        executing = NO;
        finished = NO;
        
        subQueue = [[NSOperationQueue alloc] init];
        subQueue.maxConcurrentOperationCount = 30;
        subQueue.name = @"group-operation-queue";
    }
    return self;
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
    NSMutableArray * result = [NSMutableArray array];
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        NSArray * reArr = [NSArray array];
        [result addObject:reArr];
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
            NSMutableArray * secArr = [NSMutableArray array];
            
            for (NSInteger index = 0; index < [array count]; index ++)
            {
                SessionReqModel * reqModel = [array objectAtIndex:index];
                ZWSessionReqOperation * req = [[ZWSessionReqOperation alloc] init];
                req.timeOutNum = self.timeOutNum;
                req.dataDelegate = self;
                req.reqUrl = reqModel.url;
                req.proxyDic = reqModel.proxyDic;
                req.cookieDic = reqModel.cookieDic;
                [secArr addObject:req];
                [subQueue addOperation:req];
            }
            self.sessionArr = secArr;
            
            [subQueue waitUntilAllOperationsAreFinished];
            if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(sessionRequestOperation:finishResult:)])
            {
                [self.dataDelegate sessionRequestOperation:self
                                              finishResult:self.resultArr];
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


-(void)sessionRequestOperation:(ZWSessionReqOperation *)session
                     finishReq:(NSDictionary *)backDic
                      errorDic:(NSDictionary *)errDic
{
    NSArray * arr = nil;
    if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(ZWSessionGroupOperationBackObjectArrayFromBackDataDic:)])
    {
        arr = [self.dataDelegate ZWSessionGroupOperationBackObjectArrayFromBackDataDic:backDic];
    }
    
    NSInteger index = [self.sessionArr indexOfObject:session];
    if(!arr)
    {
        arr = [NSArray array];
    }
    [self.resultArr replaceObjectAtIndex:index withObject:arr];
}



@end
