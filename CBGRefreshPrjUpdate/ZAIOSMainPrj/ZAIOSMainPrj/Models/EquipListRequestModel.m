//
//  EquipListRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/4.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "EquipListRequestModel.h"
#import "RoleDataModel.h"
@implementation EquipListRequestModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        
        self.listSession.configuration.timeoutIntervalForRequest = 100;
    }
    return self;
}

-(NSString *)replaceStringWithLatestWebString:(NSString *)webStr
{
    if(!webStr) return nil;
    //文本替换，移除 page 替换 device_id device_name os_name os_version
    NSArray * removeArr = @[@"page",
                            @"device_id",
                            @"device_name",
                            @"os_version"];
    
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
    NSString * appendStr = @"&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
    
    NSString * result = [replaceStr stringByAppendingString:appendStr];
    return result;
}

-(NSArray *)webRequestDataList
{
    NSString * pageUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/xyq_search.py?act=super_query&search_type=overall_role_search&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
    pageUrl = [self replaceStringWithLatestWebString:RefreshListRequestURLString];
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < RefreshListMaxPageNum; index ++)
    {
        NSString * eve = [NSString stringWithFormat:@"%@&page=%ld",pageUrl,(long)index];
        [urls addObject:eve];
    }
    return urls;
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
    return array;
}


@end
