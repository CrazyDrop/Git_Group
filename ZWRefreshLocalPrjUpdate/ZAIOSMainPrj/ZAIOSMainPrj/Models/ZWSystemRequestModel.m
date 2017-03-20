//
//  ZWSystemRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSystemRequestModel.h"
#import "JSONKit.h"

@interface ZWSystemRequestModel()

@property (nonatomic,strong) AFHTTPRequestOperationManager * httpManager;
@end

@implementation ZWSystemRequestModel

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
-(void)sendRequest
{
    self.isFinished = NO;
    self.sysArr = nil;
    [[self.httpManager operationQueue] cancelAllOperations];
    
    NSString * string = self.listUrl;
    [self startWebRequestWithWebUrl:string];
    
}


-(void)startWebRequestWithWebUrl:(NSString *)urlStr
{
    NSString * url =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = urlStr;
    
    AFHTTPRequestOperationManager * manager =  self.httpManager;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = total.randomAgent;
    [manager.requestSerializer setValue:str forHTTPHeaderField:@"User-Agent"];
    
//    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [manager GET:url
      parameters:nil
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
         [self doneAndCheckSystemSellDataResult:dic];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //                                         NSLog(@"%s %@",__FUNCTION__,error);
    
         [self doneAndCheckSystemSellDataResult:nil];
     }];
    [self sendSignal:self.requestLoading];
    
}

-(void)doneAndCheckSystemSellDataResult:(NSDictionary *)data
{
    NSArray * arr = [data valueForKey:@"products"];
    NSArray * dataArr = [ZWSysSellModel systemSellModelArrayFromLatestArray:arr];
    
    if(dataArr && [dataArr count]>0)
    {
        self.sysArr = dataArr;
    }
    
    self.isFinished = YES;
    if(!self.sysArr)
    {
        [self sendSignal:self.requestError];
    }else{
        [self sendSignal:self.requestLoaded];
    }
}



@end
