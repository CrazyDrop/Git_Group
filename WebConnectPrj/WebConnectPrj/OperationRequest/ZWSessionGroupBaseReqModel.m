//
//  ZWSessionGroupBaseReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWSessionGroupBaseReqModel.h"
#import "ZWSessionReqOperation.h"
#import "ZWSessionGroupOperation.h"
@interface ZWSessionGroupBaseReqModel()<ZWSessionGroupDelegate>
@property (nonatomic, strong)  NSLock *  lock;
@property (nonatomic, strong) NSMutableArray * resultArr;
@property (nonatomic, strong) NSArray * webReqArr;
@end

@implementation ZWSessionGroupBaseReqModel
-(id)init
{
    self = [super init];
    if(self){
        defaultQueue = [[NSOperationQueue alloc] init];
        defaultQueue.name = @"group-request-model-queue";
        defaultQueue.maxConcurrentOperationCount = 20;//支持20个组并发
        
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

-(void)sendRequest
{
    if(self.executing)
    {
        return;
    }
    [self.lock lock];
    self.executing = YES;
    self.listArray = nil;
    [self.lock unlock];
    
    NSMutableArray * reqArr = [NSMutableArray array];
    NSMutableArray * resArr = [NSMutableArray array];
    NSArray * modelsArr = self.reqModels;
    for (NSInteger index =0;index < [modelsArr count] ;index ++ )
    {
        NSArray * subReq = [modelsArr objectAtIndex:index];
        ZWSessionGroupOperation * group = [[ZWSessionGroupOperation alloc] init];
        group.maxOperationNum = 100;
        group.dataDelegate = self;
        group.reqModels = subReq;
        group.timeOutNum = self.timeOutCount;
        [reqArr addObject:group];
        
        NSString * randStr = [NSString stringWithFormat:@"%ld %u",index,arc4random()%100];
        [resArr addObject:randStr];
    }
    self.resultArr = resArr;
    self.webReqArr = reqArr;
    [defaultQueue addOperations:reqArr waitUntilFinished:NO];
    
    [self sendSignal:self.requestLoading];
}
-(void)checkSessionReqeustBackDataArray:(NSArray *)arr
{
    BOOL finished = YES;
    for (NSInteger index = 0;index < [arr count] ;index ++ )
    {
        NSString * eve = [arr objectAtIndex:index];
        if([eve isKindOfClass:[NSString class]])
        {
            finished = NO;
            break;
        }
    }
    
    if(finished)
    {
        [self.lock lock];
        self.listArray = arr;
        self.executing = NO;
        [self sendSignal:self.requestLoaded];
        [self.lock unlock];
    }
}


//提供解析方法，需要能满足多线程操作
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    return nil;
}


//取消请求，结束回调
-(void)cancel
{
    [defaultQueue cancelAllOperations];
    
}
-(NSArray *)ZWSessionGroupOperationBackObjectArrayFromBackDataDic:(NSDictionary *)aDic{
    return [self backObjectArrayFromBackDataDic:aDic];
}


-(void)sessionRequestOperation:(ZWSessionGroupOperation *)session
                  finishResult:(NSArray *)backArr
{
    NSInteger index = [self.webReqArr indexOfObject:session];
    NSArray * array = backArr;
    if(!array){
        array = [NSArray array];
    }
    
    @synchronized (self.resultArr)
    {
        [self.resultArr replaceObjectAtIndex:index withObject:array];
        [self checkSessionReqeustBackDataArray:self.resultArr];
    }
}


@end
