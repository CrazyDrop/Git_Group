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
//#import "CreateModel.h"
#import "RoleDataModel.h"
@interface RefreshListDataManager()
{
    NSOperationQueue * operationQueue;
    NSMutableDictionary * dataDic;
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
        manager.requestSerializer.HTTPShouldHandleCookies = NO;
    
        
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
    
    dataDic = [NSMutableDictionary dictionary];
    return self;
}
//默认排序请求
-(NSArray *)defaultSortArray
{
    
    
    
    NSArray * arr = @[
                     @"http://xyq-ios2.cbg.163.com/app2-cgi-bin//xyq_search.py?act=super_query&search_type=overall_role_search&page=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519"
                      ];;
    return arr;

}
//利率排序数组
-(NSArray *)rateSortArray
{
    NSArray * arr = nil;
    return arr;
}


-(void)startWebRequestWithWebUrl:(NSString *)url
{

    AFHTTPRequestOperationManager * manager =  self.httpManager;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = total.randomAgent;
    str = @"xyqcbg2/2.2.8 CFNetwork/758.1.6 Darwin/15.0.0";
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
        
        if(dic)
        {
            [dataDic setObject:dic forKey:url];
        }
        
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"%s %@",__FUNCTION__,error);
                                     }];
    [operationQueue addOperation:op1];
    [self.checkOpt addDependency:op1];
    
}



-(void)doneAndCheckOperationQueueResult:(id)sender
{
    if([[NSOperationQueue currentQueue] operationCount] != 1) return;

    NSTimeInterval sleepCount = 1;
//    if([UIScreen mainScreen].bounds.size.height == 480)
    {
        sleepCount = 2;
    }
    [NSThread sleepForTimeInterval:sleepCount];
    
    NSArray * orderArr = [self defaultSortArray];
    
    NSMutableArray * sortArr = [NSMutableArray array];
    for (NSInteger index = 0 ; index < [orderArr count] ; index ++ )
    {
        NSInteger backIndex = [orderArr count] - index - 1;
        NSString * url = [orderArr objectAtIndex:backIndex];
        NSDictionary * eve = [dataDic objectForKey:url];
        
        if(eve)
        {
            NSArray * arr = [self totalRefreshListDataForBackDataDic:eve];
            if(!arr)
            {
                continue;
            }
            [sortArr addObjectsFromArray:arr];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.productsArr = sortArr;
        if(!self.productsArr)
        {
            [self sendSignal:self.requestError];
        }else{
            [self sendSignal:self.requestLoaded];
        }
    });

}

-(NSArray *)totalRefreshListDataForBackDataDic:(NSDictionary *)aDic
{
    RoleDataModel * listData = [[RoleDataModel alloc] initWithDictionary:aDic];
    NSArray * array = listData.equip_list;
    if(!array || ![array isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    return array;
}

-(void)sendRequest
{
    [self startTotalSubURLString];
}
-(void)startTotalSubURLString
{
    if([operationQueue operationCount]!=0)
    {
//        [self doneAndCheckOperationQueueResult:nil];
        return;
    }
//    NSLog(@"%s operationCount %lu",__FUNCTION__,[[operationQueue operations] count]);
    
    [self cancel];
    self.checkOpt = nil;
    self.productsArr = nil;
    [dataDic removeAllObjects];
    
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
}

@end
