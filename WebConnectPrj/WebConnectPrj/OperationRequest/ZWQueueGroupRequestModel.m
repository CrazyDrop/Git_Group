//
//  ZWQueueGroupRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWQueueGroupRequestModel.h"
#import "VPNProxyModel.h"
#import "SessionReqModel.h"
#import "JSONKit.h"
@interface ZWQueueGroupRequestModel()
{
    NSOperationQueue * groupQueue;
}
@property (nonatomic, strong) NSMutableArray * resultArr;
@property (nonatomic, strong) NSArray * webReqArr;
@property (nonatomic, strong) NSMutableDictionary * cookieDic;
@property (nonatomic, strong) NSMutableDictionary * errorProxyDic;
@property (nonatomic, strong) NSArray * baseUrls;
@property (nonatomic, strong) NSMutableArray * taskArr;
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) NSArray * replaceArr;
@property (nonatomic, strong) SessionReqModel * baseReq;
@end

@implementation ZWQueueGroupRequestModel


-(id)init
{
    self = [super init];
    if(self)
    {
        self.timeOutNum = 5;
//        groupQueue = [[self class] zw_sharedGroupRequestOperationQueue];
        self.cookieDic = [NSMutableDictionary dictionary];
        self.errorProxyDic = [NSMutableDictionary dictionary];
        self.taskArr = [NSMutableArray array];
    }
    return self;
}
-(SessionReqModel *)baseReq
{
    if(!_baseReq)
    {
        SessionReqModel * aReq = [[SessionReqModel alloc] init];
        _baseReq = aReq;
    }
    return _baseReq;
}

-(void)setTimerState:(BOOL)timerState
{
    if(_timerState != timerState)
    {
        self.needUpdate = YES;
    }
    _timerState = timerState;
}

-(void)sendRequest
{
    if(self.executing)
    {
        return;
    }
    self.executing = YES;
    if(self.needUpdate)
    {
        self.needUpdate = NO;
        [self refreshWebRequestRealUrlsWithArray:nil];
        
        NSArray * urlArr = self.replaceArr;
        if(!urlArr || [urlArr count] == 0)
        {
            urlArr = [self webRequestDataList];
        }
        [self refreshWebRequestRealUrlsWithArray:urlArr];
    }
    self.listArray = nil;
    self.errorProxy = nil;
    [self.errorProxyDic removeAllObjects];
    [self.taskArr removeAllObjects];
    
    //数据检查，当屏蔽随机时，urls数量和session数量一致
    if(self.ingoreRandom)
    {
        NSAssert([self.baseUrls count] == [self.sessionArr count], @"session无随机，sessionArr baseUrls数量需一致");
    }else{
//        NSAssert([self.sessionArr count] > 0, @"session随机，sessionArr 数量大于0");
    }
    
    NSArray * urlArray = self.baseUrls;
    if(!urlArray || [urlArray count] == 0)
    {
        self.executing = NO;
        return;
    }
    
    
    //网络请求结果返回很快，结果数组未创建即
    NSMutableArray * resArr = [NSMutableArray array];
    [resArr addObjectsFromArray:urlArray];
    self.resultArr = resArr;
    
    NSMutableArray * reqArr = [NSMutableArray array];
    NSArray * sessionTotal = self.sessionArr;
    NSInteger sessionNum = [sessionTotal count];
    SessionReqModel * sessionReq = self.baseReq;
    
    for (NSInteger index = 0;index < [urlArray count] ;index ++ )
    {
        NSString * url = [urlArray objectAtIndex:index];
        NSInteger randIndex = arc4random()%sessionNum;
        if(self.ingoreRandom)
        {
            randIndex = index;
        }
        
        if(sessionNum > 0)
        {
            if(sessionNum > randIndex)
            {
                sessionReq = [sessionTotal objectAtIndex:randIndex];
            }
        }
        
        if(!sessionReq) continue;
        
//        NSBlockOperation * opt = [NSBlockOperation blockOperationWithBlock:^
//                                  {
//                                      [weakSelf startWebRequestWithSubSessionReqModel:sessionReq andURLString:url];
//                                  }];
//        [optArr addObject:opt];
        [self startWebRequestWithSubSessionReqModel:sessionReq andURLString:url andIndex:index];
        
        [reqArr addObject:sessionReq];
    }

    self.webReqArr = reqArr;
    
    //发起请求
    for (NSURLSessionTask * task in self.taskArr)
    {
        [task resume];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendSignal:self.requestLoading];;
    });
    
}
-(void)refreshWebRequestWithArray:(NSArray *)list
{
    if(self.executing) return;
    self.replaceArr = list;
    self.timerState = !self.timerState;
}

-(NSArray *)baseReqModels
{
    return self.webReqArr;
}

-(void)startWebRequestWithSubSessionReqModel:(SessionReqModel *)reqModel andURLString:(NSString *)urlStr andIndex:(NSInteger)urlIndex
{
    NSDictionary * cookie = [self cookieStateWithStartWebRequestWithUrl:urlStr];
    NSURL * url = [NSURL URLWithString:urlStr];
    NSURLSession * session = reqModel.session;
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    if(self.timeOutNum > 0)
    {
        session.configuration.timeoutIntervalForRequest = self.timeOutNum;
        request.timeoutInterval = self.timeOutNum;
    }
    
    NSString * str = @"xyqcbg2/2.2.8 CFNetwork/758.1.6 Darwin/15.0.0";
    [request setValue:str forHTTPHeaderField:@"User-Agent"];
    
    if(cookie)
    {
        [request setValue: [cookie objectForKey:@"Cookie"] forHTTPHeaderField: @"Cookie"];
    }
    
    __weak typeof(self) weakSelf = self;
    void(^finishBlock)(NSData * data ,NSURLResponse * response ,NSError * error) = ^void(NSData * responseObject ,NSURLResponse * response ,NSError * error)
    {
        
        if(weakSelf.saveCookie && [weakSelf respondsToSelector:@selector(doneWebRequestWithBackHeaderDic:andStartUrl:)])
        {
            NSDictionary *fields = ((NSHTTPURLResponse*)response).allHeaderFields;
            [weakSelf doneWebRequestWithBackHeaderDic:fields andStartUrl:urlStr];
        }
        
        NSDictionary * dic = nil;
        NSString * resultStr = nil;
        if(!error)
        {
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
            if([resultStr isEqualToString:@"EOF"] ||
               [resultStr containsString:@"Maximum number of open"] ||
               [resultStr containsString:@"no such host"] ||
               [resultStr containsString:@"<title>lid_25793</title>"] ||
               [resultStr containsString:@"Error: The requested URL could not be checked"]||
               [resultStr containsString:@"500 Internal Server Error"] ||
               [resultStr containsString:@"错误: 不能获取请求的 URL"])
            {
                dic = @{@"cbgError":resultStr};
            }else{
                NSLog(@"resultStr %@",resultStr);
            }
        }
        
        
        NSArray * subArr = nil;
        if([weakSelf respondsToSelector:@selector(sessionGroupRequestFinishWithDic:andSessionModel:)])
        {
            subArr = [self sessionGroupRequestFinishWithDic:dic andSessionModel:reqModel];
        }
        
//        NSString * checkUrl = [weakSelf.baseUrls objectAtIndex:urlIndex];
//        NSInteger index = [weakSelf.baseUrls indexOfObject:urlStr];
//        if(index == NSNotFound || ![checkUrl isEqualToString:urlStr]){
//            NSLog(@"%ld %ld %@",index,urlIndex,checkUrl);
//            NSLog(@"weakSelf.baseUrls %@",weakSelf.baseUrls);
//        }
        [weakSelf finishGroupRequestWithIndex:urlIndex
                                  andSubArray:subArr];
    };
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:finishBlock];
    
    [self.taskArr addObject:task];
}
-(NSInteger)unFinishedReqestNumberWithArray:(NSArray *)result
{
    NSInteger countNum = 0;
    NSArray * arr = result;
    for (NSInteger index = 0;index < [arr count] ;index++ )
    {
        NSString * eve = [arr objectAtIndex:index];
        if([eve isKindOfClass:[NSString class]]){
            countNum ++;
        }
    }
    return countNum;
}

-(void)finishGroupRequestWithIndex:(NSInteger)index andSubArray:(NSArray * )array
{
    @synchronized (self.resultArr)
    {
        if(!array) array = [NSArray array];
//        NSMutableArray * editArr = [NSMutableArray arrayWithArray:self.resultArr];
        
        [self.resultArr replaceObjectAtIndex:index withObject:array];
        
        NSInteger limitNum = [self unFinishedReqestNumberWithArray:self.resultArr];
//        NSString * url = [self.baseUrls objectAtIndex:index];
//        NSLog(@"limitNum %ld %ld %@",limitNum,index,url);
        if(limitNum == 0)
        {
            [self checkSessionReqeustBackDataArray:self.resultArr];
        }
    }
}


-(void)checkSessionReqeustBackDataArray:(NSArray *)array
{
    BOOL finished = YES;
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        NSString * eve = [array objectAtIndex:index];
        if([eve isKindOfClass:[NSString class]])
        {
            finished = NO;
            break;
        }
    }
    
    if(finished)
    {
        self.listArray = [NSArray arrayWithArray:array];
        self.errorProxy = [self.errorProxyDic allValues];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendSignal:self.requestLoaded];
            self.executing = NO;
        });
    }
}


-(void)refreshWebRequestRealUrlsWithArray:(NSArray *)list
{
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

-(NSArray *)sessionGroupRequestFinishWithDic:(NSDictionary *)backDic andSessionModel:(SessionReqModel *)sessionModel
{
    NSArray * result = [self backObjectArrayFromBackDataDic:backDic];
    
    @synchronized (self.errorProxyDic)
    {
        VPNProxyModel * proxy = sessionModel.proxyModel;
        if([DZUtils deviceWebConnectEnableCheck])
        {
            if([backDic objectForKey:@"webError"] || [backDic objectForKey:@"noneError"])
            {
                proxy.errorNum ++;
                if(proxy)
                {
                    [self.errorProxyDic setObject:proxy forKey:proxy.idNum];
                }
            }else if([backDic objectForKey:@"cbgError"])
            {
                proxy.errored = YES;
            }
            else{
                proxy.errorNum = 0;
                if([self.errorProxyDic objectForKey:proxy.idNum])
                {
                    [self.errorProxyDic removeObjectForKey:proxy.idNum];
                }
            }
        }
    }
    return result;
}

//取消请求，结束回调
-(void)cancel
{
    for (NSInteger index = 0;index < [self.taskArr count] ;index ++ )
    {
        NSURLSessionTask * task = [self.taskArr objectAtIndex:index];
        [task cancel];
    }
    [self.taskArr removeAllObjects];

//    [groupQueue cancelAllOperations];
    [self.errorProxyDic removeAllObjects];
}
#pragma - mark ProxyDelegate
//进行结果输出
//-(NSArray *)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
//                         finishEveReq:(NSDictionary *)backDic
//                         sessionModel:(SessionReqModel *)sessionModel
//{
//    @synchronized (self.errorProxyDic)
//    {
//        VPNProxyModel * proxy = sessionModel.proxyModel;
//        if([DZUtils deviceWebConnectEnableCheck])
//        {
//            if([backDic objectForKey:@"webError"] || [backDic objectForKey:@"noneError"])
//            {
//                proxy.errorNum ++;
//                if(proxy)
//                {
//                    [self.errorProxyDic setObject:proxy forKey:proxy.idNum];
//                }
//            }else{
//                proxy.errorNum = 0;
//                if([self.errorProxyDic objectForKey:proxy.idNum])
//                {
//                    [self.errorProxyDic removeObjectForKey:proxy.idNum];
//                }
//            }
//        }
//    }
//
//    return [self backObjectArrayFromBackDataDic:backDic];
//}
//进行结果输出
//-(void)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
//                       finishReq:(NSArray *)backDicArr
//                        errorDic:(NSArray *)errDicArr
//{
//    NSInteger index = [self.webReqArr indexOfObject:session];
//    NSArray * array = backDicArr;
//    if(!array){
//        array = [NSArray array];
//    }
//    
//    //    [self.lock lock];
//    [self.resultArr replaceObjectAtIndex:index withObject:array];
//    [self checkSessionReqeustBackDataArray:self.resultArr];
//    //    [self.lock unlock];
//}

//-(NSArray *)groupBaseRequestOperationCreateReqModels:(ZWOperationGroupBaseOperation *)session
//{
//    NSMutableArray * reqArr = [NSMutableArray array];
//    NSArray * urls = self.baseUrls;
//    for (NSInteger index = 0;index < [urls count] ;index ++ )
//    {
//        NSString * eveUrl = [urls objectAtIndex:index];
//        SessionReqModel * eve = [[SessionReqModel alloc] init];
//        eve.url = eveUrl;
//        eve.cookieDic = [self cookieStateWithStartWebRequestWithUrl:eveUrl];
//        VPNProxyModel * model = [self proxyModelWithStartWebRequestWithUrl:eveUrl];
//        eve.proxyModel = model;
//        eve.proxyDic = [model detailProxyDic];
//        [reqArr addObject:eve];
//    }
//    
//    return reqArr;
//}
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



@end
