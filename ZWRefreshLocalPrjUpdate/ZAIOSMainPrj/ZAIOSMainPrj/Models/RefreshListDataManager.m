//
//  RefreshListDataManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/7/19.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDataDetailModel.h"
#import "RefreshListDataManager.h"
#import "JSONKit.h"
@interface RefreshListDataManager()
{
    NSOperationQueue * operationQueue;
    NSMutableDictionary * dataDic;
    NSMutableDictionary * systemDic;
    NSMutableDictionary * topSoldDic;
}
@property (nonatomic,strong) NSArray * webArr;
@property (nonatomic,strong) NSOperation * checkOpt;
@property (nonatomic,strong) AFHTTPRequestOperationManager * httpManager;
@property (nonatomic,assign) BOOL cancelQueue;
@end

@implementation RefreshListDataManager

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
        manager.requestSerializer.HTTPShouldHandleCookies = YES;
        
//        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
//        [cookieProperties setObject:@"16_dec_invite_pri_partin" forKey:NSHTTPCookieName];
//        [cookieProperties setObject:@"true" forKey:NSHTTPCookieValue];
//        
//        
//        NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//        
//        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        [cookieJar setCookie:cookie];
        
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
    self.cancelQueue = NO;
    
//    self.webArr = [self rateSortArray];
    self.webArr = [self defaultSortArray];
    
    operationQueue  = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = [self.webArr count] + 1;
    
    dataDic = [NSMutableDictionary dictionary];
    systemDic = [NSMutableDictionary dictionary];
    topSoldDic = [NSMutableDictionary dictionary];
    return self;
}
//默认排序请求
-(NSArray *)defaultSortArray
{
    NSArray * arr = @[@"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=0&page_size=20&sn=1e80f08301d28e257f09d769e44797bc&sort_order=descend&sort_rule=default&timestamp=1472088446813.252&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=1&page_size=20&sn=caaf4abc7703ef8e068adb749537dcff&sort_order=descend&sort_rule=default&timestamp=1472088451812.585&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=2&page_size=20&sn=e5857da2848be0ace39f42dd66d4fc56&sort_order=descend&sort_rule=default&timestamp=1472088454745.938&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=3&page_size=20&sn=8c8e6c1c249d8c6e803facf760cd2269&sort_order=descend&sort_rule=default&timestamp=1472088457262.473&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=4&page_size=20&sn=f6cbf70e6f373021d267603d3c09260f&sort_order=descend&sort_rule=default&timestamp=1472088461148.099&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=5&page_size=20&sn=0b56bcdc9cfc9aca2a976b6e5c8624de&sort_order=descend&sort_rule=default&timestamp=1472088463980.977&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=6&page_size=20&sn=a6c26c8dcf578f63d870f4ac8f84d394&sort_order=descend&sort_rule=default&timestamp=1472088467280.463&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=7&page_size=20&sn=55a24a05f2c76fe0bf8f94d1f90ef93a&sort_order=descend&sort_rule=default&timestamp=1472088469948.014&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=8&page_size=20&sn=74db31362501c9f396a18c1d783aacf0&sort_order=descend&sort_rule=default&timestamp=1474181515490.255&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=9&page_size=20&sn=b254735f9a10abc30ae1378566650767&sort_order=descend&sort_rule=default&timestamp=1474181518040.11&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=10&page_size=20&sn=2fe2544c85ec8ac7b4ff8b1af8300ca8&sort_order=descend&sort_rule=default&timestamp=1474181522039.897&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=11&page_size=20&sn=57d39cf39379f51508e1affeacddf8d2&sort_order=descend&sort_rule=default&timestamp=1474181524288.6&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=12&page_size=20&sn=a1592b2b905dbffa496baa1eb8f6c487&sort_order=descend&sort_rule=default&timestamp=1474181526537.823&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=13&page_size=20&sn=6d1195257c2578e53d890c079c744fca&sort_order=descend&sort_rule=default&timestamp=1474181528941.128&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=14&page_size=20&sn=167d44aaaa61ea7e33b25c67586a386c&sort_order=descend&sort_rule=default&timestamp=1474181531122.957&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/product/list?device_guid=FD75E44A-B582-4A15-BC83-A176D2AD6C08&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&sn=a0f1bceafb522bd32f71cd0ba3675764&timestamp=1480582983160.324&user_id=0"
                      ];
    return arr;

}
//利率排序数组
-(NSArray *)rateSortArray
{
    NSArray * arr = @[@"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=0&page_size=20&sn=e0ab06b3a9a3f03c7c381e1cca89b0bc&sort_order=descend&sort_rule=annual_rate&timestamp=1472087991433.532&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=1&page_size=20&sn=215e4113d11337fcb54e488667b05bd7&sort_order=descend&sort_rule=annual_rate&timestamp=1472088081423.785&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=2&page_size=20&sn=40a50ef351ef1b39a3c4287b4d1c35e9&sort_order=descend&sort_rule=annual_rate&timestamp=1472088116145.172&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=3&page_size=20&sn=23ca2db3e9af70b27df66fd8d4e3d20f&sort_order=descend&sort_rule=annual_rate&timestamp=1472088137466.159&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=4&page_size=20&sn=2d65e4010b94b0c93a73ce872b9dd0c2&sort_order=descend&sort_rule=annual_rate&timestamp=1472088158486.697&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=5&page_size=20&sn=370a74fc9b91ecb39d9bce36486aa605&sort_order=descend&sort_rule=annual_rate&timestamp=1472088177553.637&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=6&page_size=20&sn=756296edba7b6101feb2371523391304&sort_order=descend&sort_rule=annual_rate&timestamp=1472088191572.168&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=7&page_size=20&sn=c82b83c5944e06c1079f67f6327b8d44&sort_order=descend&sort_rule=annual_rate&timestamp=1472088212424.787&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=8&page_size=20&sn=375807921cf9dbac754ff3da17ecaf00&sort_order=descend&sort_rule=annual_rate&timestamp=1474181866411.835&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=9&page_size=20&sn=a0c72e1a0b5ee17a676c1c02eecadec2&sort_order=descend&sort_rule=annual_rate&timestamp=1474181868610.124&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=10&page_size=20&sn=8cdb06de4a461e4b3d538a41b62997d2&sort_order=descend&sort_rule=annual_rate&timestamp=1474181870995.953&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=11&page_size=20&sn=a418ab4553d35778f782653f0f5356cd&sort_order=descend&sort_rule=annual_rate&timestamp=1474181873279.398&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=12&page_size=20&sn=eecfd950336235b8f7e16fee2e5d47bc&sort_order=descend&sort_rule=annual_rate&timestamp=1474181875478.548&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=13&page_size=20&sn=8c2d66c074c2d6aa28de22f3c9cec3eb&sort_order=descend&sort_rule=annual_rate&timestamp=1474181877530.047&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=14&page_size=20&sn=44b4cbf723ed23121d4f2c6b13e1799d&sort_order=descend&sort_rule=annual_rate&timestamp=1474181879430.412&type=liquidate&user_id=0",
                      @"https://www.91zhiwang.com/api/product/list?device_guid=FD75E44A-B582-4A15-BC83-A176D2AD6C08&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&sn=a0f1bceafb522bd32f71cd0ba3675764&timestamp=1480582983160.324&user_id=0"
                      ];
    return arr;
}


-(void)startWebRequestWithWebUrl:(NSString *)url
{

    AFHTTPRequestOperationManager * manager =  self.httpManager;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = total.randomAgent;
    if([url containsString:@"list?"]){
     str = @"ZWPRO/3.3 (iPhone; iOS 9.1; Scale/3.00)";
    }

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:str forHTTPHeaderField:@"User-Agent"];
    
    AFHTTPRequestOperation * op1 = [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
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
        
        NSArray * topSell = nil;
        NSArray * sysSell = nil;
        NSArray * proArr = [dic valueForKey:@"product_categories"];
        if(proArr)
        {
            NSDictionary * groupsDic = [proArr firstObject];
            NSArray * groups = [groupsDic valueForKey:@"product_groups"];
            for (NSDictionary * eve in groups)
            {
                NSString * groupId = [eve valueForKey:@"group_id"];
                if([groupId isEqualToString:@"normal"]){
                    sysSell = [eve valueForKey:@"products"];
                }else if([groupId isEqualToString:@"liquidate"]){
                    topSell = [eve valueForKey:@"products"];
                }
                
            }
        }
        
        NSArray * arr = [dic valueForKey:@"products"];
        if(!arr) {
            arr = topSell;
        }
        NSArray * reslut = [ZWDataDetailModel dataArrayFromJsonArray:arr];
        if(reslut)
        {
            for (ZWDataDetailModel * eve in reslut)
            {
                if(eve && eve.created_at){
                    [dataDic setObject:eve forKey:eve.created_at];
                    if(topSell)
                    {
                        [topSoldDic setObject:eve forKey:eve.created_at];
                    }
                }
            }
            if(sysSell)
            {
                NSArray * eveArr = [ZWSysSellModel systemSellModelArrayFromLatestArray:sysSell];
                [eveArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZWSysSellModel * sell = (ZWSysSellModel *)obj;
                    if([sell.duration_str intValue]>190)
                    {
                        [systemDic setObject:sell forKey:sell.name];
                    }
                }];
            }
        }
        
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                         NSLog(@"%s %@",__FUNCTION__,error);
                                     }];
    [operationQueue addOperation:op1];
    [self.checkOpt addDependency:op1];
    
}



-(void)doneAndCheckOperationQueueResult:(id)sender
{
    NSLog(@"%s %d",__FUNCTION__,[operationQueue operationCount]);
    if([[NSOperationQueue currentQueue] operationCount] != 1) return;

    NSTimeInterval sleepCount = 0.5;
    if([UIScreen mainScreen].bounds.size.height == 480){
        sleepCount = 1;
    }
    [NSThread sleepForTimeInterval:sleepCount];
    
    NSArray * dataArr = nil;
    NSArray * sysSoldArr = nil;
    NSArray * topArr = nil;
    
    if([dataDic count]>0)
    {
        dataArr =[dataDic allValues];
    }
    if([systemDic count]>0){
        sysSoldArr = [systemDic allValues];
    }
    if([topSoldDic count]>0){
     topArr = [topSoldDic allValues];
    }
    
    NSArray * sortArr = nil;
    if(dataArr && [dataArr count]>0)
    {
       sortArr = [dataArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            ZWDataDetailModel * detail1 = (ZWDataDetailModel *)obj1;
            ZWDataDetailModel * detail2 = (ZWDataDetailModel *)obj2;
            return [detail2.annual_rate_str compare:detail1.annual_rate_str];
        }];

    }

    dispatch_async(dispatch_get_main_queue(), ^{
        @weakify(self)
        self.productsArr = sortArr;
        self.topArr = topArr;
        self.systemArr = sysSoldArr;
        if(!self.productsArr)
        {
            [self sendSignal:self.requestError];
        }else{
            [self sendSignal:self.requestLoaded];
        }
    });

}


-(void)sendRequest
{
    [self startTotalSubURLString];
}
-(void)startTotalSubURLString
{
    if([operationQueue operationCount]!=0)
    {
        [self doneAndCheckOperationQueueResult:nil];
        return;
    }
//    NSLog(@"%s operationCount %lu",__FUNCTION__,[[operationQueue operations] count]);
    
    [self cancel];
    self.checkOpt = nil;
    self.productsArr = nil;
    [dataDic removeAllObjects];
    [systemDic removeAllObjects];
    [topSoldDic removeAllObjects];
    
    //启动4个网络请求operation
    for (NSString * url in self.webArr)
    {
        [self startWebRequestWithWebUrl:url];
    }
    [operationQueue addOperation:self.checkOpt];
    [self sendSignal:self.requestLoading];
}



-(void)cancel
{
     NSLog(@"%s",__FUNCTION__);
    [operationQueue cancelAllOperations];
//    self.cancelQueue = YES;
}

@end
