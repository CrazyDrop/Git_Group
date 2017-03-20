//
//  Equip_listModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "Equip_listModel.h"
#import "EquipExtraModel.h"
@implementation Equip_listModel
//-(CGFloat)earnRate
//{
//    if(!_earnRate)
//    {
//        _earnRate = [[self createLatestRate] floatValue];
//    }
//    return _earnRate;
//}
//-(NSString *)createLatestRate
//{
//    if(!self.earnPrice || !self.detaiModel.last_price_desc) return nil;
//    EquipModel * detail = self.detaiModel;
//    NSString * rate  = [NSString stringWithFormat:@"%.0f",[self.earnPrice floatValue] * 100/[detail.last_price_desc floatValue]];
//    return rate;
//}

- (NSString * )detailCheckIdentifier
{
    if(!self.price_desc || !self.game_ordersn)
    {
        return nil;
    }
    NSString * identifier = [NSString stringWithFormat:@"%@-%@",self.price_desc,self.game_ordersn];
    return identifier;
}
- (NSString * )detailDataUrl
{
    if(!self.serverid || !self.game_ordersn)
    {
        return nil;
    }
//    http://xyq-ios2.cbg.163.com/app2-cgi-bin//query.py?serverid=443&game_ordersn=525_1480680251_527287531&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519
    NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%@&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.serverid,self.game_ordersn];
    return url;
}
- (NSString * )detailWebUrl
{
    if(!self.serverid || !self.game_ordersn){
        return nil;
    }
//    http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=443&ordersn=525_1480680251_527287531&equip_refer=1
    NSString * url = [NSString stringWithFormat:@"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=%@&ordersn=%@&equip_refer=1",self.serverid,self.game_ordersn];
    return url;
    return nil;
}
//计算公式，判定账号是否值得购买
- (BOOL)preBuyEquipStatusWithCurrentExtraEquip
{
    CGFloat earnRate = self.earnRate;
    if(earnRate > 8 && [self.serverid integerValue]!=45)
    {
        return YES;
    }
    if((earnRate > 0 && self.detaiModel.equipExtra.zhaohuanPrice>1000 ) || self.detaiModel.equipExtra.zhaohuanPrice>2000)
    {
        return YES;
    }
    return NO;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    /*  [Example] change property id to productID
     *
     *  if([key isEqualToString:@"id"]) {
     *
     *      self.productID = value;
     *      return;
     *  }
     */
    
    // show undefined key
//    NSLog(@"%@.h have undefined key '%@', the key's type is '%@'.", NSStringFromClass([self class]), key, [value class]);
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    // ignore null value
    if ([value isKindOfClass:[NSNull class]]) {
        
        return;
    }
    if ([key isEqualToString:@"detaiModel"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[EquipModel alloc] initWithDictionary:value];

    }


    [super setValue:value forKey:key];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    
    return self;
}

@end

