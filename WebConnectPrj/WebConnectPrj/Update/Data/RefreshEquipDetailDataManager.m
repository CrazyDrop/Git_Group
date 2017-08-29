//
//  RefreshEquipDetailDataManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/19.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshEquipDetailDataManager.h"
#import "JSONKit.h"
#import "RoleDetailDataModel.h"

@interface RefreshEquipDetailDataManager ()
{
    NSString * _listUrl;
}
//@property (nonatomic, strong) AFHTTPRequestOperationManager * httpManager;
@end

@implementation RefreshEquipDetailDataManager

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
//        self.listUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=527&game_ordersn=1054_1485410581_1059019393&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
        self.listUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=732&game_ordersn=1268_1484454549_1268596618&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.9&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
        
//        NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%@&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.serverid,self.game_ordersn];

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
    self.detailModel = nil;
    [super sendRequest];
}

//进行数据解析
-(BOOL)doneRequestWithFinishDataDic:(NSDictionary *)dic
{
    RoleDetailDataModel * listData = [[RoleDetailDataModel alloc] initWithDictionary:dic];
    EquipModel * model = listData.equip;
    if(!model || ![model isKindOfClass:[EquipModel class]])
    {
        return NO;
    }
    self.detailModel = model;
    return YES;
}


@end
