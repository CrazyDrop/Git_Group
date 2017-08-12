//
//  ZWDefaultOperationReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWDefaultOperationReqModel.h"
#import "ZWSessionReqOperation.h"
#import "VPNProxyModel.h"
@interface ZWDefaultOperationReqModel()<ZWSessionReqDelegate>
@property (nonatomic, strong) NSMutableArray * resultArr;
@property (nonatomic, strong) NSArray * webReqArr;
@property (nonatomic, strong)  NSLock *  lock;
@property (nonatomic, strong) NSMutableDictionary * errorProxyDic;
@end
@implementation ZWDefaultOperationReqModel
-(id)init
{
    self = [super init];
    if(self){
        defaultQueue = [[NSOperationQueue alloc] init];
        defaultQueue.name = @"operation-request-model-queue";
        defaultQueue.maxConcurrentOperationCount = 30;
        
        self.errorProxyDic = [NSMutableDictionary dictionary];
        self.baseUrls = [self webRequestDataList];
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

-(void)sendRequest
{//都是主线程进行
    if(self.executing)
    {
        return;
    }
    [self.lock lock];
    self.executing = YES;
    self.listArray = nil;
    self.errorProxy = nil;
    [self.errorProxyDic removeAllObjects];
    [self.lock unlock];

    NSArray * list = self.baseUrls;
    
    NSMutableArray * req = [NSMutableArray array];
    NSMutableArray * result = [NSMutableArray array];
    for (NSInteger index = 0;index < [list count] ;index ++ )
    {
        NSString * eveUrl = [list objectAtIndex:index];
        ZWSessionReqOperation * ope = [[ZWSessionReqOperation alloc] init];
        ope.timeOutNum = self.timeOutNum;
        ope.dataDelegate = self;
        ope.reqUrl = eveUrl;
        ope.cookieDic = [self cookieStateWithStartWebRequestWithUrl:eveUrl];
        VPNProxyModel * model = [self proxyModelWithStartWebRequestWithUrl:eveUrl];
        ope.proxyModel = model;
        ope.proxyDic = model.detailProxyDic;
        [req addObject:ope];
        [result addObject:eveUrl];
    }
    self.webReqArr = req;
    self.resultArr = result;
    
    [defaultQueue addOperations:req waitUntilFinished:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendSignal:self.requestLoading];;
    });

}

-(void)refreshWebRequestWithArray:(NSArray *)list
{
    if(self.executing) return;
    self.baseUrls = list;
}

//提供请求url数组
-(NSArray *)webRequestDataList
{
    return nil;
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
    self.resultArr = nil;
    [self.errorProxyDic removeAllObjects];
}

#pragma mark - privateMethods
//-(NSDictionary *)proxyModelWithStartWebRequestWithUrl:(NSString *)url
//{
//    return nil;
//}
-(VPNProxyModel *)proxyModelWithStartWebRequestWithUrl:(NSString *)url
{
    NSInteger proNum = [self.proxyArr count];
    
    NSInteger randIndex =  arc4random()%proNum;
    if([self.proxyArr count] > randIndex)
    {
        VPNProxyModel * model = [self.proxyArr objectAtIndex:randIndex];
        return model;
    }
    
    return nil;
}

-(NSDictionary *)cookieStateWithStartWebRequestWithUrl:(NSString *)url
{
    return nil;
}
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)dic andStartUrl:(NSString *)url
{
    
}

#pragma mark - ZWSessionReqDelegate
-(void)sessionRequestOperation:(ZWSessionReqOperation *)session
                     finishReq:(NSDictionary *)backDic
                      errorDic:(NSDictionary *)errDic
{
    NSInteger index = [self.webReqArr indexOfObject:session];
    NSArray * array = [self backObjectArrayFromBackDataDic:backDic];
    if(!array){
        array = [NSArray array];
    }
    
    @synchronized (self.resultArr)
    {
        VPNProxyModel * proxy = session.proxyModel;
        
        if([DZUtils deviceWebConnectEnableCheck])
        {
            if([backDic objectForKey:@"webError"] || [backDic objectForKey:@"noneError"])
            {
                proxy.errorNum ++;
                [self.errorProxyDic setObject:proxy forKey:proxy.idNum];
            }else{
                proxy.errorNum = 0;
                if([self.errorProxyDic objectForKey:proxy.idNum])
                {
                    [self.errorProxyDic removeObjectForKey:proxy.idNum];
                }
            }
        }
        
        [self.resultArr replaceObjectAtIndex:index withObject:array];
        [self checkSessionReqeustBackDataArray:self.resultArr];
    }
}

-(void)sessionRequestOperation:(ZWSessionReqOperation *)session doneWebRequestBackHeaderDic:(NSDictionary *)dic andStartUrl:(NSString *)url
{
    //session处理
    [self doneWebRequestWithBackHeaderDic:dic andStartUrl:url];
    
}
#pragma mark - resultCheck
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
        self.errorProxy = [self.errorProxyDic allValues];
        self.executing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendSignal:self.requestLoaded];;
        });
        [self.lock unlock];
    }
}



@end
