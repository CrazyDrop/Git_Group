//
//  BBListModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "BBListModel.h"

@implementation BBListModel

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
    // keyword_arg
    if ([key isEqualToString:@"keyword_arg"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Keyword_argModel alloc] initWithDictionary:value];
    }

    // order_headers
    if ([key isEqualToString:@"order_headers"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Order_headersModel *model = [[Order_headersModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // equip_list
    if ([key isEqualToString:@"equip_list"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Equip_listModel *model = [[Equip_listModel alloc] initWithDictionary:dictionary];
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

