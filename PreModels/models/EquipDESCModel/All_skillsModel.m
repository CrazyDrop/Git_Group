//
//  All_skillsModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "All_skillsModel.h"
#import "ExtraModel.h"
@implementation All_skillsModel

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
    if ([key isEqualToString:@"skillsArray"] && [value isKindOfClass:[NSArray class]])
    {
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            ExtraModel *model = [[ExtraModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        
        ExtraModel * model = [[ExtraModel alloc] initWithDictionary:value];
        [self.skillsArray addObject:model];
        model.extraTag = key;
    }
//    if ([key isEqualToString:@"name"] && [value isKindOfClass:[NSString class]]) {
//        
//        ExtraModel * model = [[ExtraModel alloc] initWithDictionary:value];
//        [self.skillsArray addObject:model];
//        model.extraName = value;
//        model.extraTag = key;
//    }
//    if ([key isEqualToString:@"skillsArray"] && [value isKindOfClass:[NSArray class]]) {
//        
//        ExtraModel * model = [[ExtraModel alloc] initWithDictionary:value];
//        [self.skillsArray addObject:model];
//        model.extraTag = key;
//    }

    [super setValue:value forKey:key];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self.skillsArray = [NSMutableArray array];

    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    
    return self;
}

@end

