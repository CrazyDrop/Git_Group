//
//  ZWServerEquipModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerEquipModel.h"

@implementation ZWServerEquipModel

-(NSString *)description
{
    NSMutableString * edit = [NSMutableString string];
    [edit appendFormat:@"serverid %ld  equipId %ld",self.serverId,self.equipId];
    if(self.equipDesc){
        [edit appendString:@"des"];
    }
    return edit;
}

- (NSString * )mobileAppDetailShowUrl
{
    if(!self.orderSN)
    {
        return nil;
    }
    
    NSString * baseUrl = @"netease-xyqcbg://show_equip/";
    NSString * url = [NSString stringWithFormat:@"?view_loc=link_qq&ordersn=%@&server_id=%ld&equip_refer=328" ,self.orderSN,(long)self.serverId];
    url = [baseUrl stringByAppendingString:url];
    return url;
    
}
- (NSString * )detailDataUrl
{
    if(!self.orderSN)
    {
        return nil;
    }
    //    http://xyq-ios2.cbg.163.com/app2-cgi-bin//query.py?serverid=443&game_ordersn=525_1480680251_527287531&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519
    NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%ld&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.serverId,self.orderSN];
    return url;
}

@end
