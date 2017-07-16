//
//  HighlightModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "HighlightModel.h"
#import "ExtraModel.h"
@implementation HighlightModel

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

    [super setValue:value forKey:key];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self.infoArray = [NSMutableArray array];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }else if([dictionary isKindOfClass:[NSArray class]])
    {
        NSArray * arr = (NSArray *)dictionary;
        if([dictionary count] == 2)
        {
            ExtraModel * model = [[ExtraModel alloc] init];
            [self.infoArray addObject:model];
            model.extraValue = [arr lastObject];
            model.extraTag = [arr firstObject];
        }
    }
    
    return self;
}

@end

