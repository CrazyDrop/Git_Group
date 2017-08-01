//
//  EquipModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "EquipModel.h"
#import "NSData+Extension.h"
#import "NSDate+Extension.h"
@implementation EquipModel
-(BOOL)isAutoStopSelling
{
    if(!self.equipExtra) return NO;
    
    EquipModel * detail = self;
    //    NSString * leftTime = detail.sell_expire_time_desc;
    
    NSDate * sellDate = [NSDate fromString:detail.selling_time];
    NSDate * finishDate = [NSDate dateWithTimeInterval:DAY * 14 sinceDate:sellDate];
    NSDate * nowDate = [NSDate date];
    
    //使用商品锁定时间、用户下架也会造成，没有自动下架时间，只能默认14天使用
    //    finishDate = [NSDate fromString:detail.equip_lock_time];
    NSTimeInterval interval = [nowDate timeIntervalSinceDate:finishDate];
    if(interval > 0)
    {
        return YES;
    }
    
    return NO;
}


+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"statuses" : @"MJStatus",
             @"ads" : @"MJAd"
             };
}

-(CBGEquipRoleState)equipState
{
    CBGEquipRoleState status = CBGEquipRoleState_None;
    NSInteger number = [self.status integerValue];
    switch (number)
    {
        case 0:
        {
            status = CBGEquipRoleState_Backing;
        }
            break;
        case 1:
        {
            status = CBGEquipRoleState_unSelling;
        }
            break;
        case 2:
        {
            status = CBGEquipRoleState_InSelling;
        }
            break;
            
        case 3:
        {
            status = CBGEquipRoleState_InOrdering;
        }
            break;
        case 4:
        {
            status = CBGEquipRoleState_PayFinish;
        }
            break;
        case 5:
        {
            //交易完成，认为和购买一致
            status = CBGEquipRoleState_BuyFinish;
        }
            break;
        case 6:
        {
            status = CBGEquipRoleState_BuyFinish;
        }
            break;
            
        default:
            break;
    }
    
    return status;
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
    // bargain_info
    if ([key isEqualToString:@"bargain_info"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Bargain_infoModel alloc] initWithDictionary:value];
    }

    // cross_buy_serverids
    if ([key isEqualToString:@"cross_buy_serverids"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Cross_buy_serveridsModel *model = [[Cross_buy_serveridsModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // highlight
    if ([key isEqualToString:@"highlight"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            HighlightModel *model = [[HighlightModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // selling_info
    if ([key isEqualToString:@"selling_info"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Selling_infoModel *model = [[Selling_infoModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // poundage_list
    if ([key isEqualToString:@"poundage_list"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Poundage_listModel *model = [[Poundage_listModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }
    if ([key isEqualToString:@"equipExtra"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[EquipExtraModel alloc] initWithDictionary:value];
        
    }

    [super setValue:value forKey:key];
}
-(NSDictionary *)detailDesDicFromCurrentDesc
{
    NSString * result = self.equip_desc;
    
    return nil;
}
-(NSString *)equipSoldOutResultTime
{
    NSString * soldTime = nil;
    for (NSInteger index = 0; index < [self.selling_info count]; index ++)
    {
        Selling_infoModel * info = [self.selling_info objectAtIndex:index];
        if(info.soldTime)
        {
            soldTime = info.soldTime;
        }
    }
    if(!soldTime) return nil;
//         03-30 13:24 //补全时间数据，售出时间没有年份，
//    2017-03-31 17:32:08
//    self.fair_show_end_time
    NSDate * showDate = [NSDate fromString:self.selling_time];
    showDate = [showDate dateByAddingTimeInterval:-1 * DAY];
    NSString * soldDateStr = [NSString stringWithFormat:@"%ld-%@:00",showDate.year,soldTime];
    NSDate * soldDate = [NSDate fromString:soldDateStr];//当售出时间早于展示时间，
    //公示期结束的时间
    if([soldDate timeIntervalSinceDate:showDate] < 0)
    {
        soldDateStr = [NSString stringWithFormat:@"%ld-%@:00",showDate.year + 1,soldTime];
    }

    return soldDateStr;
}
-(NSString *)equipCancelBackResultTime
{
    NSString * soldTime = nil;
    for (NSInteger index = 0; index < [self.selling_info count]; index ++)
    {
        Selling_infoModel * info = [self.selling_info objectAtIndex:index];
        if(info.backTime)
        {
            soldTime = info.backTime;
        }
    }
    if(!soldTime) return nil;
    //         03-30 13:24 //补全时间数据
    //    2017-03-31 17:32:08
    NSDate * nowDate = [NSDate date];
    NSString * soldDateStr = [NSString stringWithFormat:@"%ld-%@:00",nowDate.year,soldTime];
    return soldDateStr;
}

-(NSString *)detailStatusDes
{
    NSString * statusDes = nil;
    NSInteger number = [self.status integerValue];
    switch (number)
    {
        case 0:
        {
            statusDes = @"已取回";
        }
            break;
        case 1:
        {
            statusDes = @"暂存";
//            status = CBGEquipRoleState_unSelling;
        }
            break;
        case 2:
        {
            statusDes = @"上架中";
//            status = CBGEquipRoleState_InSelling;
        }
            break;
            
        case 3:
        {
            statusDes = @"下单中";
//            status = CBGEquipRoleState_InOrdering;
        }
            break;
        case 4:
        {
            statusDes = @"已付款";
//            status = CBGEquipRoleState_PayFinish;
        }
            break;
        case 5:
        {
            //交易完成，认为和购买一致
            statusDes = @"已取走";
//            status = CBGEquipRoleState_BuyFinish;
        }
            break;
        case 6:
        {
            statusDes = @"已取走";
//            status = CBGEquipRoleState_BuyFinish;
        }
            break;
            
        default:
            break;
    }
    return statusDes;
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

