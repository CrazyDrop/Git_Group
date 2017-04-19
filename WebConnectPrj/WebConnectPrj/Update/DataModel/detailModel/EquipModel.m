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

-(CGFloat)createEquipExtraEarnRate
{
    CGFloat soldPrice = [[self.equipExtra buyPrice] floatValue];
    CGFloat costPrice = [self.price floatValue]/100.0;
    
    //缴税
    CGFloat earnTotal = soldPrice * 0.95 -  costPrice;
    if(costPrice > 0 && earnTotal > 0 )
    {
        CGFloat rate = earnTotal / (costPrice + 0.0);
        rate *= 100;
        self.earnPrice = soldPrice * 0.95 -  costPrice;
        
//        NSLog(@"earnRate %.2f",rate);
        return rate;
    }
    return 0;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"statuses" : @"MJStatus",
             @"ads" : @"MJAd"
             };
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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    
    return self;
}

@end

