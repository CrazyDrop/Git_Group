//
//  UserInfo.m
//  Photography
//
//  Created by jialifei on 15/4/6.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

static UserInfo * userInfo = nil;

+ (UserInfo *) sharedUser
{
    if (userInfo == nil) {
        userInfo = [[UserInfo alloc] init];
    }
    return userInfo;
}

@end
