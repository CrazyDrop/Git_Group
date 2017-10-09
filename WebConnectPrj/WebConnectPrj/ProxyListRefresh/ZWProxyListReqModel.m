//
//  ZWProxyListReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/9/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWProxyListReqModel.h"
#import "RoleDetailDataModel.h"
#import "JSONKit.h"
#import "CBGListModel.h"
@implementation ZWProxyListReqModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        //        self.listSession.configuration.timeoutIntervalForRequest = 60;
    }
    return self;
}

-(NSArray *)webRequestDataList
{
    //单一数据，填充ip获取url
    NSString * pageUrl = @"http://api.zdaye.com/?api=201709291814275802&rtype=1&ct=1000";
    pageUrl = @"http://api.zdaye.com/?api=201710081542247089&rtype=1&ct=1000";
    
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < 1; index ++)
    {
//        NSString * eve = [NSString stringWithFormat:@"%@&page=%ld",pageUrl,(long)index];
        [urls addObject:pageUrl];
    }
    return urls;
}
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
//    ZWProxyListReqModel
//    CBGListModel\sell_start_time\game_ordersn
    NSString * subStr = [aDic objectForKey:@"proxy"];
    if([subStr length] > 0)
    {
        NSString * sepKey = @"\r\n";
        NSArray * dataArr = [subStr componentsSeparatedByString:sepKey];
        NSMutableArray * models = [NSMutableArray array];
        
        for (NSString * eveStr in dataArr)
        {
            CBGListModel * eve = [self proxyModelWithIpString:eveStr];
            [models addObject:eve];
        }
        
        if([models count] > 0)
        {
            return models;
        }

    }
    return nil;
}
-(CBGListModel *)proxyModelWithIpString:(NSString *)ipStr
{
    CBGListModel * list = [[CBGListModel alloc] init];
    list.game_ordersn = ipStr;
    list.sell_start_time = [NSDate unixDate];
    return list;
}


@end
