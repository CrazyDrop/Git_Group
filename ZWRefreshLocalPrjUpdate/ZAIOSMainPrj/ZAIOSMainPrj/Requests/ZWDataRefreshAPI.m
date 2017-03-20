//
//  ZWDataRefreshAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDataRefreshAPI.h"
#import "NSObject+AutoCoding.h"
#import "JSONKit.h"



@implementation ZWDataRefreshHTTPRequest
@end

@implementation ZWDataRefreshHTTPResponse
@end

@interface ZWDataRefreshHTTPApi()
//未能共用STIHTTPSessionManager网络请求中心
@property (nonatomic,strong) STIHTTPSessionManager * sessionManager;

@end
@implementation ZWDataRefreshHTTPApi
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZWDataRefreshHTTPRequest alloc] initWithEndpoint:@"" method:STIHTTPRequestMethodGet];
        self.req.responseClass = [ZWDataRefreshHTTPResponse class];
    }
    return self;
}

-(STIHTTPSessionManager *)sessionManager
{
    if(!_sessionManager)
    {
        //        ?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0&location=39.983424,116.322987
        NSString * locationUrl = @"https://www.91zhiwang.com/api/liquidate/product";
//        locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=creditease&device_guid=c0bf79b0eda5fc741de3e8d6e397ace2&device_model=YQ601&page_no=0&page_size=10&session_id=d35c016ceff84370c87eed9cf1448c2d3d8a145233225fd987acf9103d3f89cb7cad5ababf64c7886810a3a4b463cccae74b8e3fce724e05&timestamp=1457335665829&user_id=10476676&sn=a4ea4870e7892eaf5f91b9c05d7f612d";
        
        
//        STIHTTPSessionManager * client = [[STIHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:locationUrl]];
        STIHTTPSessionManager * client = [[STIHTTPSessionManager alloc] init];

        client.requestSerializer = [AFHTTPRequestSerializer serializer];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager = client;
    }
    return _sessionManager;
}

-(instancetype)shareLocationAPI
{
    static ZWDataRefreshHTTPApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //        //        &location=39.983424,116.322987
        //        NSString * locationUrl = @"https://api.map.baidu.com/geocoder/v2/?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0";
        //
        //        _sharedClient = [[STIHTTPRequestManager alloc] initWithBaseURL:[NSURL URLWithString:locationUrl]];
        //        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        //        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient = [[ZWDataRefreshHTTPApi alloc] init];
    });
    return _sharedClient;
}

-(void)send
{
    if ( self.sessionManager.setup )
    {
        self.sessionManager.setup(nil);
    }
    
    //        ?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0&location=39.983424,116.322987
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    
    NSString * str = total.randomAgent;
    if(!str) str = @"Chrome HK";
    AFHTTPRequestSerializer * requestSlizer = self.sessionManager.requestSerializer;
    [requestSlizer setValue:str forHTTPHeaderField:@"User-Agent"];
    requestSlizer.timeoutInterval = 5;
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    [parameters addEntriesFromDictionary:self.req.parameters];
    [parameters setValue:@"creditease" forKey:@"channel"];
    [parameters setValue:@"c0bf79b0eda5fc741de3e8d6e397ace2" forKey:@"device_guid"];
    [parameters setValue:@"YQ601" forKey:@"device_model"];
    [parameters setValue:@"0" forKey:@"page_no"];
    [parameters setValue:@"10" forKey:@"page_size"];
    [parameters setValue:@"d35c016ceff84370c87eed9cf1448c2de80446c54b88914e800192be89d63073b2dd06e6a1ddcc114acd1e3431cb48a211204f7688876db6" forKey:@"session_id"];
    [parameters setValue:@"1457420384874" forKey:@"timestamp"];
    [parameters setValue:@"10476676" forKey:@"user_id"];
    [parameters setValue:@"156355427d01bca8b5d2b4818137a2a5" forKey:@"sn"];
    
    AFHTTPSessionManager * manager = self.sessionManager;
    
//    [self.sessionManager method:STIHTTPRequestMethodGet
//                       endpoint:self.req.endpoint
//                     parameters:parameters
//                        success:^(NSURLSessionDataTask *task, id responseObject) {
//                            //                                __strong typeof(weakSelf) self = weakSelf;
//                            NSArray * arr = [responseObject valueForKey:@"products"];
//                            NSArray * reslut = [ZWDataRefreshResponseDetail dataArrayFromJsonArray:arr];
//                            
//                            self.responseObject = reslut;
//                            if ( self.whenUpdate ) {
//                                self.whenUpdate( self.resp, nil );
//                            }
//                        }
//                        failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
//                            
//                            [self.sessionManager handleError:error responseObject:responseObject task:task failureBlock:self.whenUpdate];
//                        }];
    
    NSString * locationUrl = @"https://www.91zhiwang.com/api/liquidate/product";
    
    locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=creditease&device_guid=c0bf79b0eda5fc741de3e8d6e397ace2&device_model=YQ601&page_no=0&page_size=10&session_id=d35c016ceff84370c87eed9cf1448c2de80446c54b88914e800192be89d63073b2dd06e6a1ddcc114acd1e3431cb48a211204f7688876db6&timestamp=1457420384874&user_id=10476676&sn=156355427d01bca8b5d2b4818137a2a5";
    locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=xiaomi&device_guid=8609550223310982fa52f8017096546a&device_model=MI+2S&page_no=0&page_size=10&timestamp=1462936189773&user_id=0&sn=abe82f64c6632b42721389005e5db5de";

//    locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=xiaomi&device_guid=8609550223310982fa52f8017096546a&device_model=MI+2S&page_no=0&page_size=10&sort_order=descend&sort_rule=annual_rate&timestamp=1462938191832&user_id=0&sn=defe808579eee9d548d59ff8307ead4d";

    
    if(total.localURL1) locationUrl = total.localURL1;
    if(self.nextPage)
    {
        locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=creditease&device_guid=c0bf79b0eda5fc741de3e8d6e397ace2&device_model=YQ601&page_no=1&page_size=10&session_id=d35c016ceff84370c87eed9cf1448c2de80446c54b88914e800192be89d63073b2dd06e6a1ddcc114acd1e3431cb48a211204f7688876db6&timestamp=1457420398365&user_id=10476676&sn=dd49cf6012b993232eaeb209db6e9e44";
        locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=xiaomi&device_guid=8609550223310982fa52f8017096546a&device_model=MI+2S&page_no=1&page_size=10&sort_order=descend&sort_rule=annual_rate&timestamp=1462938413189&user_id=0&sn=4e4fe4eda9846412e5d1562e5bfc79cd";
        locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=xiaomi&device_guid=8609550223310982fa52f8017096546a&device_model=MI+2S&page_no=0&page_size=10&sort_order=descend&sort_rule=annual_rate&timestamp=1462938191832&user_id=0&sn=defe808579eee9d548d59ff8307ead4d";
//        locationUrl = @"https://www.91zhiwang.com/api/liquidate/product?channel=xiaomi&device_guid=8609550223310982fa52f8017096546a&device_model=MI+2S&page_no=1&page_size=10&sort_order=descend&sort_rule=annual_rate&timestamp=1462938413189&user_id=0&sn=4e4fe4eda9846412e5d1562e5bfc79cd";


        if(total.localURL2) locationUrl = total.localURL2;

    }
    parameters = nil;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * aTask = [manager GET:locationUrl
      parameters:parameters
         success:^(NSURLSessionDataTask *task, id responseObject)
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
             NSArray * arr = [dic valueForKey:@"products"];
             NSArray * reslut = [ZWDataDetailModel dataArrayFromJsonArray:arr];
             
             self.responseObject = reslut;
             if ( self.whenUpdate ) {
                 self.whenUpdate( self.resp, nil );
             }

         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"AFHTTPResponseSerializer %@",error);
         }];
    self.task = aTask;
    
}

//-(void)cancel
//{
//    [super cancel];
//}
@end

