//
//  1Model.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "ExtraModel.h"

@implementation ExtraModel

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
-(NSInteger)equipLatestAddLevel
{
    //    锻炼等级 3  镶嵌

    NSInteger level = 0;
    NSString * des = self.cDesc;
    NSString * startStr = @"锻炼等级 ";
    NSString * finishStr = @"  镶嵌";
    NSRange startRange = [des rangeOfString:startStr];
    NSRange finishRange = [des rangeOfString:finishStr];
    if(startRange.length > 0 && finishRange.length > 0){
        NSInteger startIndex = startRange.length + startRange.location;
        NSString * subStr = [des substringWithRange:NSMakeRange(startIndex,finishRange.location - startIndex)];
        level = [subStr integerValue];

    }
    
    return level;
}
-(NSString *)equipAppendSkill{
//    特技：#c4DBAF4诅咒之伤#Y#Y#r#W制造
    return nil;
}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }else if([dictionary isKindOfClass:[NSNumber class]])
    {
        NSNumber * value = (NSString *)dictionary;
//        if([DZUtils checkSubCharacterIsNumberString:value])
        {
            self.extraValue = value;
        }
    }
    
    return self;
}

@end

