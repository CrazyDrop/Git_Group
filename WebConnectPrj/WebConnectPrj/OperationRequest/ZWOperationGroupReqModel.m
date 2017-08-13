//
//  ZWOperationGroupReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/13.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWOperationGroupReqModel.h"
#import "ZWSessionReqOperation.h"
#import "ZWSessionGroupOperation.h"
#import "ZWOperationGroupBaseOperation.h"
#import "VPNProxyModel.h"
@interface ZWOperationGroupReqModel()<ZWOperationGroupBaseOperationDelegate>
@property (nonatomic, strong)  NSLock *  lock;
@property (nonatomic, strong) NSMutableArray * resultArr;
@property (nonatomic, strong) NSArray * webReqArr;
@property (nonatomic, strong) NSMutableDictionary * cookieDic;
@property (nonatomic, strong) NSMutableDictionary * errorProxyDic;
@property (nonatomic, strong) NSArray * baseUrls;

@end

@implementation ZWOperationGroupReqModel
-(NSArray *)baseReqModels
{
    ZWOperationGroupBaseOperation * group = nil;
    if([self.webReqArr count] > 0){
        group = [self.webReqArr lastObject];
    }
    return group.reqModels;
}
-(id)init
{
    self = [super init];
    if(self){
        defaultQueue = [[NSOperationQueue alloc] init];
        defaultQueue.name = @"group-request-model-queue";
        defaultQueue.maxConcurrentOperationCount = 20;//支持20个组并发
        
        self.cookieDic = [NSMutableDictionary dictionary];
        self.errorProxyDic = [NSMutableDictionary dictionary];
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
//    [self.lock lock];//主线程上的条件锁
    self.executing = YES;
    self.listArray = nil;
    self.errorProxy = nil;
    [self.errorProxyDic removeAllObjects];

//    [self.lock unlock];
    
    NSMutableArray * reqArr = [NSMutableArray array];
    NSMutableArray * resArr = [NSMutableArray array];
    
    ZWOperationGroupBaseOperation * group = [[ZWOperationGroupBaseOperation alloc] init];
//    group.maxOperationNum = 100;
    group.dataDelegate = self;
    group.timeOutNum = self.timeOutNum;
    [reqArr addObject:group];
    
    NSString * randStr = [NSString stringWithFormat:@"%d %u",1,arc4random()%100];
    [resArr addObject:randStr];
    
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
        self.listArray = [arr lastObject];
        self.errorProxy = [self.errorProxyDic allValues];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendSignal:self.requestLoaded];
            self.executing = NO;
        });
    }
}

-(void)refreshWebRequestWithArray:(NSArray *)list
{
    if(self.executing) return;
    self.baseUrls = list;
}

//提供解析方法，需要能满足多线程操作
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    return nil;
}
-(NSArray *)webRequestDataList{
    return nil;
}

//取消请求，结束回调
-(void)cancel
{
    [defaultQueue cancelAllOperations];
    [self.errorProxyDic removeAllObjects];
}
#pragma - mark ProxyDelegate
//进行结果输出
-(NSArray *)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
                         finishEveReq:(NSDictionary *)backDic
                         sessionModel:(SessionReqModel *)sessionModel
{
    @synchronized (self.errorProxyDic)
    {
        VPNProxyModel * proxy = sessionModel.proxyModel;
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
    }

    return [self backObjectArrayFromBackDataDic:backDic];
}
//进行结果输出
-(void)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
                       finishReq:(NSArray *)backDicArr
                        errorDic:(NSArray *)errDicArr
{
    NSInteger index = [self.webReqArr indexOfObject:session];
    NSArray * array = backDicArr;
    if(!array){
        array = [NSArray array];
    }
    
    [self.lock lock];
    [self.resultArr replaceObjectAtIndex:index withObject:array];
    [self checkSessionReqeustBackDataArray:self.resultArr];
    [self.lock unlock];
}

-(void)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
     doneWebRequestBackHeaderDic:(NSDictionary *)dic
                     andStartUrl:(NSString *)url
{
    [self doneWebRequestWithBackHeaderDic:dic andStartUrl:url];
}
-(NSArray *)groupBaseRequestOperationCreateReqModels:(ZWOperationGroupBaseOperation *)session
{
    NSMutableArray * reqArr = [NSMutableArray array];
    NSArray * urls = self.baseUrls;
    for (NSInteger index = 0;index < [urls count] ;index ++ )
    {
        NSString * eveUrl = [urls objectAtIndex:index];
        SessionReqModel * eve = [[SessionReqModel alloc] init];
        eve.url = eveUrl;
        eve.cookieDic = [self cookieStateWithStartWebRequestWithUrl:eveUrl];
        VPNProxyModel * model = [self proxyModelWithStartWebRequestWithUrl:eveUrl];
        eve.proxyModel = model;
        eve.proxyDic = [model detailProxyDic];
        [reqArr addObject:eve];
    }
    
    return reqArr;
}
#pragma mark - 

-(NSDictionary *)cookieStateWithStartWebRequestWithUrl:(NSString *)url
{
    if(!self.saveCookie){
        return nil;
    }
    //    NSRange range = [url rangeOfString:@"server_id="];
    //    if(range.location != NSNotFound)
    //    {
    //        NSInteger startIndex = range.location + range.length;
    //        NSString * subStr = [url substringWithRange:NSMakeRange(startIndex,[url length] - startIndex)];
    
    NSString * subStr = @"shareCookie";
    
    NSDictionary * serverDic = [self.cookieDic objectForKey:subStr];
    //内含cookie
    if([serverDic count] > 0){
        NSArray * arrCookies = [serverDic allValues];
        NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:arrCookies];
        return dictCookies;
    }
    //    }
    return nil;
}
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)fields andStartUrl:(NSString *)urlStr{
    //    NSLog(@"NSDictionary %@",fields);
    if(!self.saveCookie)
    {
        return ;
    }
    
    NSURL * url = [NSURL URLWithString:urlStr];
    NSArray * normalArr = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:url];
    NSArray *  cookies= normalArr;
    //    [self checkAndRefreshLocalWebCookieArray:normalArr];
    
    //    NSRange range = [urlStr rangeOfString:@"server_id="];
    //    if(range.location != NSNotFound)
    {
        //        NSInteger startIndex = range.location + range.length;
        //        NSString * subStr = [urlStr substringWithRange:NSMakeRange(startIndex,[urlStr length] - startIndex)];
        NSString * subStr = @"shareCookie";
        
        NSDictionary * serverDic = [self.cookieDic objectForKey:subStr];
        NSMutableDictionary * editDic = [NSMutableDictionary dictionaryWithDictionary:serverDic];
        for (NSInteger index = 0;index < [cookies count] ;index ++ )
        {
            NSHTTPCookie * cookie = [cookies objectAtIndex:index];
            [editDic setObject:cookie forKey:cookie.name];
        }
        
        [self.cookieDic setObject:editDic forKey:subStr];
    }
}
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



@end
