//
//  EquipSNAutoModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "EquipSNAutoModel.h"
#define EquipOrderSnSeperateTag @"_"

@interface EquipSNAutoModel ()
@property (nonatomic, assign) NSInteger startNum;
@property (nonatomic, assign) NSInteger latestIdNum;
@property (nonatomic, assign) NSInteger equipId;
@end
@implementation EquipSNAutoModel


-(id)initWithEquipSN:(NSString *)orderSn andEquipId:(NSInteger)equipId
{
    if(self)
    {
        if(orderSn)
        {
            NSArray * arr = [orderSn componentsSeparatedByString:EquipOrderSnSeperateTag];
            if([arr count] == 3)
            {
                self.startNum = [[arr objectAtIndex:0] integerValue];
                self.timeNum = [[arr objectAtIndex:1] integerValue];
                self.latestIdNum = [[arr objectAtIndex:2] integerValue];
                self.orderSN = orderSn;
                self.equipId = equipId;
            }
        }
    }
    return self;
}
-(NSInteger)nextEquipId
{
    return self.equipId + 1;
}
-(NSString *)latestOrderSN
{
    NSString * tag = EquipOrderSnSeperateTag;
    NSString * str = [NSString stringWithFormat:@"%ld%@%ld%@%ld",self.startNum,tag,self.timeNum,tag,self.latestIdNum];
    return str;
}
- (NSString * )detailDataUrl
{
    if(!self.serverId || !self.latestOrderSN)
    {
        return nil;
    }
    //    http://xyq-ios2.cbg.163.com/app2-cgi-bin//query.py?serverid=443&game_ordersn=525_1480680251_527287531&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519
    NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%@&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.serverId,self.latestOrderSN];
    return url;
}
-(NSString *)nextOrderSN
{
    NSString * tag = EquipOrderSnSeperateTag;
    NSString * str = [NSString stringWithFormat:@"%ld%@%ld%@%ld",self.startNum,tag,self.timeNum,tag,self.latestIdNum + 1];
    return str;
}
- (NSString * )nextTryDetailDataUrl
{
    if(!self.serverId || !self.nextOrderSN)
    {
        return nil;
    }
    //    http://xyq-ios2.cbg.163.com/app2-cgi-bin//query.py?serverid=443&game_ordersn=525_1480680251_527287531&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519
    NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%@&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.serverId,self.nextOrderSN];
    return url;
}



@end
