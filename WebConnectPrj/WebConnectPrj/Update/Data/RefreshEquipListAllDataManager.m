//
//  RefreshEquipListAllDataManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/4.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshEquipListAllDataManager.h"

@implementation RefreshEquipListAllDataManager

-(NSArray *)defaultSortArray
{
    NSArray * arr = @[
                     @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/xyq_search.py?act=super_query&search_type=overall_role_search&page=1&platform=ios&app_version=2.2.9&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8"
                      ];
    
    
    NSString * pageUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/xyq_search.py?act=super_query&search_type=overall_role_search&platform=ios&app_version=2.2.9&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
//    &page=1
    
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < 15; index ++)
    {
        NSString * eve = [NSString stringWithFormat:@"%@&page=%ld",pageUrl,(long)index];
        [urls addObject:eve];
    }
    return urls;
    
    return arr;
}



@end
