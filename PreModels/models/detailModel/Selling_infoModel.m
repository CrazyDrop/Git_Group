//
//  Selling_infoModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "Selling_infoModel.h"
#import "ExtraModel.h"
@implementation Selling_infoModel

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
        if([arr count] == 2)
        {
            ExtraModel * model = [[ExtraModel alloc] init];
            [self.infoArray addObject:model];
            model.extraTag = [arr firstObject];
            model.extraString = [arr lastObject];
        }
    }
    
    return self;
}
-(NSString *)soldTime
{
    NSString * finishTime = nil;
    for (NSInteger index = 0;index < [self.infoArray count] ;index ++ )
    {
        ExtraModel * model = [self.infoArray objectAtIndex:index];
        NSString * tag = model.extraTag;
        if([tag isEqualToString:@"售出"])
        {
            finishTime = model.extraString;
        }
    }
    return finishTime;
}
-(NSString *)backTime
{
    NSString * finishTime = nil;
    for (NSInteger index = 0;index < [self.infoArray count] ;index ++ )
    {
        ExtraModel * model = [self.infoArray objectAtIndex:index];
        NSString * tag = model.extraTag;
        if([tag isEqualToString:@"已取回"])
        {
            finishTime = model.extraString;
        }
    }
    return finishTime;
}

@end

