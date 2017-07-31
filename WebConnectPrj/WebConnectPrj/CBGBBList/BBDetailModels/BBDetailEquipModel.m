//
//  EquipModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "BBDetailEquipModel.h"

@implementation BBDetailEquipModel

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
    NSLog(@"%@.h have undefined key '%@', the key's type is '%@'.", NSStringFromClass([self class]), key, [value class]);
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    // ignore null value
    if ([value isKindOfClass:[NSNull class]]) {
        
        return;
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

