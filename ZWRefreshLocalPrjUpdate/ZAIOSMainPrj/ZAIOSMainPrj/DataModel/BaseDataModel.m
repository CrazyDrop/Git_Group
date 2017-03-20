//
//  BaseDataModel.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"
#import <objc/runtime.h>
@implementation BaseDataModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:[NSString stringWithFormat:@"%@",key]];
    }
    free (properties);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
            if([key isEqualToString:@"rateUpdate"]){
                continue;
            }
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free (properties);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copyObject = [[[self class] allocWithZone:zone] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [self valueForKey:key];
        [copyObject setValue:value forKey:key];
    }
    free (properties);
    return copyObject;
}


@end
