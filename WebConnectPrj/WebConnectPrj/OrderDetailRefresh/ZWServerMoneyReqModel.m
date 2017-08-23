//
//  ZWServerMoneyReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/19.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerMoneyReqModel.h"
#import "RoleDataModel.h"
@interface ZWServerMoneyReqModel ()
@property (nonatomic, assign) BOOL needUpdate;
@end
@implementation ZWServerMoneyReqModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        //        &sum_exp_min=111
        //        &qian_neng_guo=33
        //        &skill_qiang_shen=22
    }
    return self;
}

-(NSString *)replaceStringWithLatestWebString:(NSString *)webStr andServerId:(NSString *)server
{
    if(!webStr) return nil;
    //文本替换，移除 page 替换 device_id device_name os_name os_version
    NSArray * removeArr = @[@"page",
                            @"device_id",
                            @"device_name",
                            @"os_version",
                            @"level_min"];
    
    NSString * sepStr = @"&";
    NSArray * sepArr = [webStr componentsSeparatedByString:sepStr];
    NSMutableArray * replaceArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sepArr count];index ++)
    {
        NSString * eveStr = [sepArr objectAtIndex:index];
        //        device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8;
        NSArray * eveArr = [eveStr componentsSeparatedByString:@"="];
        NSString * eveSubStr = [eveArr firstObject];
        
        if([removeArr containsObject:eveSubStr])
        {
            continue;
        }
        [replaceArr addObject:eveStr];
    }
    
    NSString * replaceStr = [replaceArr componentsJoinedByString:sepStr];
    NSString * appendStr = @"&sum_exp_max=2000";
    appendStr = @"";
    //去掉设备号
    
    //增加随机参数，尽可能防止屏蔽
    //        &sum_exp_min=111
    //        &qian_neng_guo=33
    //        &skill_qiang_shen=22
    NSInteger randMinExp = arc4random() % 10 + 1;
    NSInteger randQianneng = arc4random() % 50 + 1;
    NSInteger skill_qiang_shen = arc4random() % 20 + 1;
    //    appendStr = [appendStr stringByAppendingFormat:@"&sum_exp_min=%ld&skill_qiang_shen=%ld",randMinExp,skill_qiang_shen];
    appendStr = [appendStr stringByAppendingString:@"&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1"];
    appendStr = [appendStr stringByAppendingFormat:@"&act=super_query&search_type=query&serverid=%@&app_version=2.2.9",server];
    appendStr = [appendStr stringByAppendingString:@"&page=1"];
    
    
    
    NSString * result = [replaceStr stringByAppendingString:appendStr];
    
    
    return result;
}

-(NSArray *)webRequestDataList
{
    NSString * pageUrl = MobileRefresh_ListRequest_Default_URLString;
    
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSArray * serverArr = self.serverArr;
    NSInteger totalNum = [serverArr count];
    
    for (NSInteger index = 0; index < totalNum; index ++)
    {
        NSString * server = [serverArr objectAtIndex:index];
        NSString * deviceId = [self replaceDeviceIdWithPageIndex:index];
        NSString * requestUrl = [self replaceStringWithLatestWebString:pageUrl andServerId:server];
        requestUrl = [requestUrl stringByAppendingFormat:@"&device_id=%@",deviceId];
        [urls addObject:requestUrl];
    }
    
    return urls;
}
-(NSString *)replaceDeviceIdWithPageIndex:(NSInteger)index
{
    NSString * orderString = [NSString stringWithFormat:@"DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8%@%ld",[NSDate unixDate],index];
    NSString * md5Str = [orderString MD5String];
    
    orderString = [orderString stringByAppendingString:@"再来"];
    NSString * nexMd5 = [orderString MD5String];
    
    NSMutableString * total = [NSMutableString string];
    [total appendString:md5Str];
    [total appendString:nexMd5];
    
    NSString * compareStr = @"DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
    NSArray * arr = [compareStr componentsSeparatedByString:@"-"];
    
    NSInteger startIndex = 0;
    for (NSInteger index = 0; index < [arr count] ;index ++ )
    {
        NSInteger eveIndex = [[arr objectAtIndex:index] length];
        startIndex += eveIndex;
        [total insertString:@"-" atIndex:startIndex];
        startIndex += 1;
    }
    NSString * result = [total substringWithRange:NSMakeRange(0, [compareStr length])];
    return result;
}

-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    RoleDataModel * listData = [[RoleDataModel alloc] initWithDictionary:aDic];
    NSArray * array = listData.equip_list;
    if(!array || ![array isKindOfClass:[NSArray class]])
    {
        //        NSLog(@"error %@ %@",NSStringFromClass([self class]),[aDic allKeys]);
        return nil;
    }
    if([listData.num_per_page integerValue] == 1)
    {
        Equip_listModel * eve = [array firstObject];
        NSLog(@"role %@ %@",eve.game_ordersn,eve.sell_expire_time_desc);
    }
    
    return array;
}


@end
