//
//  VPNProxyModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "VPNProxyModel.h"

@implementation VPNProxyModel

-(id)initWithDetailDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        self.idNum = [dic valueForKey:(id)kCFNetworkProxiesHTTPProxy];
        self.portNum = [[dic valueForKey:(id)kCFNetworkProxiesHTTPPort] stringValue];
    }
    return self;
}

-(NSDictionary *)detailProxyDic
{
//    @
//    {
//        (id)kCFNetworkProxiesHTTPEnable:@YES,
//        (id)kCFNetworkProxiesHTTPProxy:@"1.2.3.4",
//        (id)kCFNetworkProxiesHTTPPort:@8080
//    };
    
    NSMutableDictionary * proxy = [NSMutableDictionary dictionary];
//    if(self.https)
//    {
//        [proxy setObject:@YES forKey:(id)kCFNetworkProxiesHTTPSEnable];
//    }else{
//        [proxy setObject:@YES forKey:(id)kCFNetworkProxiesHTTPEnable];
//    }
    
    [proxy setObject:@YES forKey:(id)kCFNetworkProxiesHTTPEnable];
    [proxy setObject:self.idNum forKey:(id)kCFNetworkProxiesHTTPProxy];
    [proxy setObject:[NSNumber numberWithInteger:[self.portNum integerValue]] forKey:(id)kCFNetworkProxiesHTTPPort];
    
    return  proxy;
}

+(NSArray *)localSaveProxyArray
{
    NSMutableArray * data = [NSMutableArray array];
    VPNProxyModel * eve = nil;
    
    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"27.148.151.181";
    eve.portNum = @"80";
    [data addObject:eve];

    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"61.54.219.75";
    eve.portNum = @"8080";
    [data addObject:eve];

    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"218.241.196.230";
    eve.portNum = @"80";
    [data addObject:eve];
    
    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"114.215.102.168";
    eve.portNum = @"8081";
    [data addObject:eve];

    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"218.58.209.8";
    eve.portNum = @"8888";
    [data addObject:eve];

    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"60.162.61.44";
    eve.portNum = @"8888";
    [data addObject:eve];

    eve = [[VPNProxyModel alloc] init];
    eve.idNum = @"47.94.99.79";
    eve.portNum = @"3128";
    [data addObject:eve];

    NSArray * dicArr = [VPNProxyModel proxyDicArrayFromDetailProxyArray:data];
    
    return dicArr;
}
+(NSArray *)proxyDicArrayFromDetailProxyArray:(NSArray *)data
{
    NSMutableArray * dicArr =[NSMutableArray array];
    for (NSInteger index = 0;index < [data count] ;index ++ )
    {
        VPNProxyModel * model = [data objectAtIndex:index];
        [dicArr addObject:model.detailProxyDic];
    }
    return dicArr;
}

@end
