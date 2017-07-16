//
//  Summon_coreModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "Summon_coreModel.h"
#import "ExtraModel.h"

@implementation Summon_coreModel

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
    if ([key isEqualToString:@"sumonModelsArray"] && [value isKindOfClass:[NSArray class]])
    {
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            ExtraModel *model = [[ExtraModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }
    if([value isKindOfClass:[NSArray class]])
    {
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        ExtraModel * model = [[ExtraModel alloc] init];
        [dataArray addObject:model];
        model.extraTag = key;
        model.cDesc = [array componentsJoinedByString:@","];
        
        [self.sumonModelsArray addObjectsFromArray:dataArray];
        
    }


    [super setValue:value forKey:key];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self.sumonModelsArray = [NSMutableArray array];

    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    
    return self;
}

@end

