//
//  RefreshDefaultListRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/4.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshDefaultListRequestModel.h"
#import "JSONKit.h"

@interface RefreshDefaultListRequestModel ()
{
    NSOperationQueue * jsonQueue;
    NSOperationQueue * operationQueue;
    NSMutableDictionary * resultDic;
    NSCache * taskCache;
//    NSLock * finishLock;
}

@property (nonatomic, assign) BOOL oneRequest;
@property (nonatomic, strong) NSArray * taskArray;
@property (nonatomic, strong) NSArray * requestArr;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, assign) BOOL runFinish;

//@property (nonatomic, strong) NSURLSession * listSession;
@end

@implementation RefreshDefaultListRequestModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.requestArr = [self webRequestDataList];
        
        taskCache = [[NSCache alloc] init];
        
        resultDic = [NSMutableDictionary dictionary];
        
        operationQueue  = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount =  20;
        
        jsonQueue = [[NSOperationQueue alloc] init];
        jsonQueue.maxConcurrentOperationCount = 20;
        [jsonQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];

    }
    return self;
}
-(NSURLSession *)listSession
{
    if(!_listSession)
    {
        //屏蔽所有缓存
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
//        config.connectionProxyDictionary =@
//        {
//            (id)kCFNetworkProxiesHTTPEnable:@YES,
//            (id)kCFNetworkProxiesHTTPProxy:@"183.222.102.104",
//            (id)kCFNetworkProxiesHTTPPort:@8080
////            @"HTTPEnable":@YES,
////            (id)kCFStreamPropertyHTTPProxyHost:@"1.2.3.4",
////            (id)kCFStreamPropertyHTTPProxyPort:@8080,
////            @"HTTPSEnable":@YES,
////            (id)kCFStreamPropertyHTTPSProxyHost:@"1.2.3.4",
////            (id)kCFStreamPropertyHTTPSProxyPort:@8080
//        };
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                              delegate:nil
                                                         delegateQueue:jsonQueue];
        self.listSession = session;
    }
    return _listSession;
}
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)dicStr andStartUrl:(NSString *)url
{
    
}
-(NSDictionary *)cookieStateWithStartWebRequestWithUrl:(NSString *)url
{
    return nil;
}

//提供请求url数组
-(NSArray *)webRequestDataList
{
    NSArray * array = nil;
    array = @[
              @"http://xyq-ios2.cbg.163.com/app2-cgi-bin//xyq_search.py?act=super_query&search_type=overall_role_search&page=1&platform=ios&app_version=2.2.9&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519"
      ];
    
    return array;
}

-(void)refreshWebRequestWithArray:(NSArray *)array
{
//    NSLog(@"%s %@",__FUNCTION__,array);
    self.requestArr = array;
    self.oneRequest = [array count] == 1;
}


//提供解析方法，需要能满足多线程操作
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    return nil;
}


//取消请求，结束回调
-(void)cancel
{
    self.cancelled = YES;
    self.oneRequest = NO;
    [operationQueue cancelAllOperations];
    [self.listSession invalidateAndCancel];
    self.listSession = nil;
    [jsonQueue removeObserver:self forKeyPath:@"operationCount"];
    [jsonQueue cancelAllOperations];
    
    
    self.executing = NO;
    @synchronized (resultDic) {
        self.taskArray = nil;
        [resultDic removeAllObjects];
    }
}


-(void)sendRequest
{
//    NSLog(@"%@ executing %d %d",NSStringFromClass([self class]),self.executing,[NSThread isMainThread]);
    //主线程进来
    if(self.executing)
    {
        return;
    }
    self.executing = YES;
    self.finished = NO;
    self.cancelled = NO;
    self.runFinish = NO;

    [operationQueue cancelAllOperations];
    [jsonQueue cancelAllOperations];
    
    @synchronized (resultDic)
    {
        [resultDic removeAllObjects];
        self.taskArray = nil;
    }
    
//    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    for (NSHTTPCookie *cookie in cookiesArray)
//    {
//        if([cookie.name isEqualToString:@"sid"])
//        {
//            if([cookie.value length] == 0){
//                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//            }
//        }
//        NSLog(@"name %@ %@",cookie.name,cookie.value);
////        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//    }
//    
//    NSArray * refreshArr = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    
    self.errNum  = 0;
    if(self.oneRequest)
    {
        NSArray * urls = self.requestArr;
        NSString * urlStr  = [urls lastObject];
        [self startOnReqeustOperationForUrlString:urlStr];

    }else{
        NSMutableArray * operations = [NSMutableArray array];
        NSArray * urls = self.requestArr;
        for (NSInteger index = 0; index < [urls count]; index ++)
        {
            NSString * urlStr  = [urls objectAtIndex:index];
            NSURLSessionTask * task = [self requestOperationForUrlString:urlStr];
            [operations addObject:task];
        }
        self.taskArray = operations;

    }
    [self sendSignal:self.requestLoading];
}
-(void)startOnReqeustOperationForUrlString:(NSString *)urlStr
{
//    NSLog(@"%s %@",__FUNCTION__,urlStr);
    //所有返回均在主线程操作
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = weakSelf.listSession;
//    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];

    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    void(^finishBlock)(NSData * data ,NSURLResponse * response ,NSError * error) = ^void(NSData * responseObject ,NSURLResponse * response ,NSError * error)
    {
        if(weakSelf.saveCookie)
        {
            if([response respondsToSelector:@selector(allHeaderFields)])
            {
                NSDictionary *fields = ((NSHTTPURLResponse*)response).allHeaderFields;
                [weakSelf doneWebRequestWithBackHeaderDic:fields andStartUrl:urlStr];
            }
        }
        
        NSDictionary * dic = nil;
        if(!error)
        {
//            NSLog(@"%s %@ %@ %ld",__FUNCTION__,urlStr,error,[responseObject length]);
            NSString * resultStr = nil;
            if(responseObject && [responseObject length]>0)
            {
                resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                if(!resultStr)
                {
                    resultStr = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                    
                }
                
                if(!resultStr || [resultStr containsString:@"action"] || [resultStr hasPrefix:@"<!DOCTYPE html PUBLIC"])
                {
                    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    resultStr = [[NSString alloc] initWithData:responseObject encoding:encode];
                    if([resultStr hasPrefix:@"出错"])
                    {
                        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:resultStr,@"msg", nil];
                        resultStr = [dic JSONString];
                    }
                }
                
            }
            dic = [resultStr objectFromJSONString];
            
            if([resultStr hasPrefix:@"<!DOCTYPE html PUBLIC"])
            {
                dic = @{@"html":resultStr};
            }

            if(!dic){
                NSLog(@"%s %@ ",__FUNCTION__,resultStr);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf doneWithRequestBackDic:dic andUrl:urlStr andError:error];
            [weakSelf finishListRequestWithOperationFinished];
        });
    };
    
    
    // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
    
    //    NSURLSessionTask *task = [session dataTaskWithURL:url
    //                                    completionHandler:finishBlock];
    
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    
    NSString * str = @"xyqcbg2/2.2.8 CFNetwork/758.1.6 Darwin/15.0.0";
    [request setValue:str forHTTPHeaderField:@"User-Agent"];
    if(self.withHost){
        [request setValue:@"xyq-ios2.cbg.163.com" forHTTPHeaderField:@"Host"];
    }
    NSDictionary * cookie = [self cookieStateWithStartWebRequestWithUrl:urlStr];
    if(cookie)
    {
        [request setValue: [cookie objectForKey:@"Cookie"] forHTTPHeaderField: @"Cookie"];
    }
//    [request setHTTPShouldHandleCookies:cookie];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:finishBlock];
    
    
    // 启动任务
    [task resume];
}


-(NSURLSessionTask *)requestOperationForUrlString:(NSString *)urlStr
{
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = weakSelf.listSession;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    void(^finishBlock)(NSData * data ,NSURLResponse * response ,NSError * error) = ^void(NSData * responseObject ,NSURLResponse * response ,NSError * error)
    {
        if(weakSelf.saveCookie)
        {
            if([response respondsToSelector:@selector(allHeaderFields)])
            {
                NSDictionary *fields = ((NSHTTPURLResponse*)response).allHeaderFields;
                [weakSelf doneWebRequestWithBackHeaderDic:fields andStartUrl:urlStr];
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
                

            }
            dic = [resultStr objectFromJSONString];
            if([resultStr hasPrefix:@"<!DOCTYPE html PUBLIC"])
            {
                dic = @{@"html":resultStr};
            }
            if([resultStr containsString:@"\r\n"])
            {
                dic = @{@"proxy":resultStr};
            }


        }
        [weakSelf doneWithRequestBackDic:dic andUrl:urlStr andError:error];
    };
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];

    
    NSString * str = @"xyqcbg2/2.2.8 CFNetwork/758.1.6 Darwin/15.0.0";
    [request setValue:str forHTTPHeaderField:@"User-Agent"];
    if(self.withHost){
        [request setValue:@"xyq-ios2.cbg.163.com" forHTTPHeaderField:@"Host"];
    }

    NSDictionary * cookie = [self cookieStateWithStartWebRequestWithUrl:urlStr];
    if(cookie)
    {
        [request setValue: [cookie objectForKey:@"Cookie"] forHTTPHeaderField: @"Cookie"];
    }
//    [request setHTTPShouldHandleCookies:cookie];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:finishBlock];
    
    
    // 启动任务
    [task resume];
    
    return task;
}
-(void)doneWithRequestBackDic:(NSDictionary *)dic andUrl:(NSString *)url andError:(NSError *)error
{
    if(error)
    {
        self.errNum ++;
        NSLog(@"doneWithRequestBackDic %@ %@",error.domain,url);
    }
    self.requestUrl = url;
    NSArray * array = [self backObjectArrayFromBackDataDic:dic];
    
    if(!array){
        array = [NSArray array];
    }
    //解决多线程回调数据存储失败，死锁
    @synchronized (resultDic)
    {
        [resultDic setObject:array forKey:url];
    }
    
}

-(void)finishListRequestWithOperationFinished
{
    if(self.cancelled) return;
    
//    NSArray * orderArr = self.requestArr;
    
    NSArray * orderArr = self.requestArr;
    NSDictionary * finishDic = nil;
    @synchronized (resultDic)
    {
        if([resultDic count] != [orderArr count])
        {
            return;
        }
        finishDic = [resultDic copy];
    }
    
    
    NSMutableArray * sortArr = [NSMutableArray array];
    for (NSInteger index = 0 ; index < [orderArr count] ; index ++ )
    {
        NSInteger backIndex = [orderArr count] - index - 1;
        backIndex = index;
        NSString * url = [orderArr objectAtIndex:backIndex];
        id eve = [finishDic objectForKey:url];
        
        if(!eve)
        {
            eve = [NSNull null];
        }
        [sortArr addObject:eve];
    }
    
    self.listArray = sortArr;
    if(!self.listArray)
    {
        [self sendSignal:self.requestError];
    }else{
        [self sendSignal:self.requestLoaded];
    }
    
    self.finished = YES;
    self.executing = NO;
    self.runFinish = NO;
//    NSLog(@"%@ executing finish %d %d",NSStringFromClass([self class]),self.executing,[NSThread isMainThread]);
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(self.oneRequest) return;
    if(object == jsonQueue && [keyPath isEqualToString:@"operationCount"])
    {
        if(self.cancelled) return;
        
        if([change[NSKeyValueChangeNewKey] intValue] != 0)
        {
            return;
        }
        //解决一起请求，两次回调
        NSArray * orderArr = self.requestArr;
        if([resultDic count] != [orderArr count])
        {
            return;
        }
        
        
        if(self.runFinish)
        {
            return;
        }
        self.runFinish = YES;
        
        dispatch_async(dispatch_get_main_queue(),^
        {
            [self finishListRequestWithOperationFinished];
        });
        

    }
}



@end
