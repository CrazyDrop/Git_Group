//
//  ZAOUrlForRemoteData.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/15.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIUrlForRequest.h"

@implementation ZAIUrlForRequest

+ (NSString *)domainNameForUserRegister:(ZAIUrlType)type
{
    if (type == ZAOUrlTypeTested)
    {
        return @"http://10.139.32.222:9080/za-clare/app/user/register";
    }
    else
    {
        return @"http://10.139.32.222:9080/za-clare/app/user/register";
    }
}

+ (NSString *)urlForUserRegisterWithType:(ZAIUrlType)type
{
    return [self domainNameForUserRegister:type];
}

+ (NSString *)urlForZATestAPIWithType:(ZAIUrlType)type
{
    if (type == ZAOUrlTypeTested)
    {
        return @"http://10.139.32.222:9080/za-clare/app/user/getUserInfo/123";
    }
    else
    {
        return @"http://10.139.32.222:9080/za-clare/app/user/getUserInfo/123";
    }
}
@end
