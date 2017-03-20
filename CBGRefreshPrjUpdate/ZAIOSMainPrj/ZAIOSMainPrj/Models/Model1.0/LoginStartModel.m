//
//  LoginStartModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/22.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LoginStartModel.h"

@implementation LoginStartModel

-(BOOL)userTimingOutOfControlForState
{

    if([self.status intValue] == 7)
    {
        return YES;
    }
    return NO;
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
