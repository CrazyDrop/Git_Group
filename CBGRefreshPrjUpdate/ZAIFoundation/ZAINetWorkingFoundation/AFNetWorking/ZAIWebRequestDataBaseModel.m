//
//  ZAORequestData.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/15.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequestDataBaseModel.h"
#import <objc/runtime.h>

@implementation ZAIWebRequestDataBaseModel

-(NSDictionary *)dictionaryForPropertys
{
    unsigned int outCount, i;
    NSMutableDictionary *dics = [NSMutableDictionary dictionary];
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [self valueForKey:key];
        [dics setObject:value forKey:key];
    }
    free (properties);
    
    return dics;
}

@end
