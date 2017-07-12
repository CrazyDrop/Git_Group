//
//  ChildModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "ChildModel.h"

@implementation ChildModel

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
    
    // summon_equip2
    if ([key isEqualToString:@"summon_equip2"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Summon_equip2Model alloc] initWithDictionary:value];
    }

    // summon_equip1
    if ([key isEqualToString:@"summon_equip1"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Summon_equip1Model alloc] initWithDictionary:value];
    }

    // all_skills
    if ([key isEqualToString:@"all_skills"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[All_skillsModel alloc] initWithDictionary:value];
    }
    
    if ([key isEqualToString:@"all_skills"] && [value isKindOfClass:[NSArray class]])
    {
        NSDictionary * valueDic = nil;
        if([value count]>0){
            valueDic = [value lastObject];
        }
        value = [[All_skillsModel alloc] initWithDictionary:valueDic];
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

