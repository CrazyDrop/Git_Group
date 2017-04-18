//
//  ZWDefaultRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/19.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDefaultRequestModel.h"
#import "JSONKit.h"

@interface ZWDefaultRequestModel()


@end

@implementation ZWDefaultRequestModel

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
    
    NSString * string = self.webUrl;
    [self startWebRequestWithWebUrl:string];
    
}


-(void)startWebRequestWithWebUrl:(NSString *)urlStr
{
    NSString * url =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = urlStr;
    
    AFHTTPRequestOperationManager * manager =  self.httpManager;
    
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    NSString * str = total.randomAgent;
//    [manager.requestSerializer setValue:str forHTTPHeaderField:@"User-Agent"];
    
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
         [self doneWebRequestWithWebDic:dic];
         
     } failure:^(AFHTTPRequestOperation *opeation, NSError *error) {
         //                                         NSLog(@"%s %@",__FUNCTION__,error);
         
         [self doneWebRequestWithWebDic:nil];
     }];
    [self sendSignal:self.requestLoading];
    
}



-(void)doneWebRequestWithWebDic:(NSDictionary *)data
{
//    NSLog(@"%s %lu",__FUNCTION__,(unsigned long)[[data allKeys] count]);
    if(self.doneZWDefaultRequestWithFinishBlock)
    {
        BOOL result = self.doneZWDefaultRequestWithFinishBlock(data);
        if(!result)
        {
            [self sendSignal:self.requestError];
        }else{
            [self sendSignal:self.requestLoaded];
        }
    }
}


@end
