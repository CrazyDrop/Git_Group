//
//  RefreshEquipListDataManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/19.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshEquipListDataManager.h"
#import "JSONKit.h"
#import "RoleDataModel.h"
@interface RefreshEquipListDataManager ()
{
    NSString * _listUrl;
}
//@property (nonatomic, strong) AFHTTPRequestOperationManager * httpManager;
@end

@implementation RefreshEquipListDataManager

-(void)setListUrl:(NSString *)listUrl
{
    _listUrl = listUrl;
    self.webUrl = listUrl;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.listUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/xyq_search.py?act=super_query&search_type=overall_role_search&page=1&platform=ios&app_version=2.2.9&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
        
        __weak  typeof(self) weakSelf = self;
        self.doneZWDefaultRequestWithFinishBlock = ^BOOL(NSDictionary * data)
        {
           return  [weakSelf doneRequestWithFinishDataDic:data];
        };
        
    }
    return self;
}

-(void)sendRequest
{
    self.listArray = nil;
    [super sendRequest];
}

//进行数据解析
-(BOOL)doneRequestWithFinishDataDic:(NSDictionary *)dic
{
    RoleDataModel * listData = [[RoleDataModel alloc] initWithDictionary:dic];
    NSArray * array = listData.equip_list;
    if(!array || ![array isKindOfClass:[NSArray class]])
    {
        return NO;
    }
    self.listArray = [NSArray arrayWithArray:array];
    return YES;
}



@end
