//
//  ZWSystemTotalRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/25.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSystemTotalRequestModel.h"
#import "ZWSystemRequestModel.h"
#import "JSONKit.h"

@interface ZWSystemTotalRequestModel()
{
    NSOperationQueue * operationQueue;
}

@property (nonatomic,strong) NSArray * webArr;
@property (nonatomic,strong) NSOperation * checkOpt;
@property (nonatomic,strong) AFHTTPRequestOperationManager * httpManager;
@end


@implementation ZWSystemTotalRequestModel

-(NSOperation *)checkOpt
{
    if(!_checkOpt)
    {
        __weak typeof(self) weakSelf = self;
        NSOperation * check = [NSBlockOperation blockOperationWithBlock:^{
            [weakSelf doneAndCheckOperationQueueResult:nil];
        }];
        self.checkOpt = check;
    }
    return _checkOpt;
}
-(AFHTTPRequestOperationManager *)httpManager
{
    if(!_httpManager)
    {
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 5;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.httpManager = manager;
    }
    return _httpManager;
}

-(id)init
{
    self = [super init];
    

    //测试
    
    self.webArr = @[
                    @"http://www.baidu.com",
                    @"http://www.baidu.com",
                    @"http://www.baidu.com",
                    @"http://www.baidu.com"
                    ];
    //    self.webArr = [self rateSortArray];
    self.webArr = [self defaultSortArray];
    
    operationQueue  = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = [self.webArr count] + 1;
    
    self.dataArr = [NSMutableArray array];
    
    return self;
}
-(NSArray *)defaultSortArray
{
    NSArray * arr = @[
                      @"https://www.91zhiwang.com/api/product/list?device_guid=47590D3D-FDD5-49EB-A292-8FE733282562&device_model=iPhone6%2C2&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&session_id=dbb2b4c4759da891b302357a51e1fb8920341501a07e2f45784b9ab70d5f772168fc7293c7b0794d5badf672fcaae28c584a1fc40b3d8543&sn=66fc77708967cdd756b5e6e2f8373185&timestamp=1471228775365.419&user_id=10990659",
                      @"https://www.91zhiwang.com/api/product/list?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&session_id=9423adb5802b75acb70f331a8eadb96fb48df88b2de240fd8b582c25f9a663e0191e07cb9f8af82f3574364b275cf1d937d8b7d8779c9cf7&sn=23b73bf9501dc47939fab69b3a29eeb5&timestamp=1471396096950.982&user_id=11105593",
                      @"https://www.91zhiwang.com/api/product/list?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&sn=dcf1556dfb8c7c7a2597a8685c28a456&timestamp=1470984959685.582&user_id=0"];
    return arr;
}

-(void)sendRequest
{
    if([operationQueue operationCount]!=0)
    {
        //        NSLog(@"operationQueue %d",[[operationQueue operations] count]);
        return;
    }
    NSLog(@"%s operationCount %lu",__FUNCTION__,[[operationQueue operations] count]);
    
    [self cancel];
    self.checkOpt = nil;
    self.sysArr = nil;
    [self.dataArr removeAllObjects];
    
    //启动4个网络请求operation
    for (NSString * url in self.webArr)
    {
        [self startWebRequestWithWebUrl:url];
    }
    [operationQueue addOperation:self.checkOpt];
    
    [self sendSignal:self.requestLoading];
}
-(void)startWebRequestWithWebUrl:(NSString *)url
{
    
    AFHTTPRequestOperationManager * manager =  self.httpManager;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = total.randomAgent;
    [manager.requestSerializer setValue:str forHTTPHeaderField:@"User-Agent"];
//    NSLog(@"strstr %@",str);
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPRequestOperation * op1 = [manager HTTPRequestOperationWithRequest:request
                                                                    success:^(AFHTTPRequestOperation *operation, id responseObject)
                                    {
                                        //                                         NSLog(@"%s %d",__FUNCTION__,[responseObject length]);
                                        NSString * resultStr = nil;
                                        if(responseObject && [responseObject length]>0)
                                        {
                                            resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                            
                                            if(!resultStr)
                                            {
                                                resultStr = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                                                
                                            }
                                        }
                                        
                                        NSDictionary * dic = [resultStr objectFromJSONString];
                                        NSLog(@"absoluteString %@",[operation.request.URL absoluteString]);
                                        [self doneAndCheckOperationQueueResult:dic];
                                                                                
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"%s %@",__FUNCTION__,error);
                                        id responseObject = operation.responseData;
                                        NSString * resultStr = nil;
                                        if(responseObject && [responseObject length]>0)
                                        {
                                            resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                            
                                            if(!resultStr)
                                            {
                                                resultStr = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                                                
                                            }
                                        }
                                        
                                        NSDictionary * dic = [resultStr objectFromJSONString];
                                        
                                        [self doneAndCheckOperationQueueResult:dic];

                                    }];
    [operationQueue addOperation:op1];
    [self.checkOpt addDependency:op1];
    
}
-(void)checkWebResponseWithResultDic:(NSDictionary *)data
{
    if(!data) return;
    NSArray * arr = [data valueForKey:@"products"];
    
    if(!arr) return;
    NSArray * eveArr = [ZWSysSellModel systemSellModelArrayFromLatestArray:arr];
    [self.dataArr addObjectsFromArray:eveArr];
}


-(void)doneAndCheckOperationQueueResult:(NSDictionary *)data
{
    [self checkWebResponseWithResultDic:data];
    
    NSLog(@"%s %d",__FUNCTION__,[operationQueue operationCount]);
    if([[NSOperationQueue currentQueue] operationCount] != 1) {
        return;
    }
    
    [NSThread sleepForTimeInterval:0.1];
    
    self.sysArr = self.dataArr;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        @weakify(self)
        
        if(!self.sysArr)
        {
            [self sendSignal:self.requestError];
        }else{
            [self sendSignal:self.requestLoaded];
        }
    });

}
-(void)cancel
{
    NSLog(@"%s",__FUNCTION__);
    [operationQueue cancelAllOperations];
}


@end
