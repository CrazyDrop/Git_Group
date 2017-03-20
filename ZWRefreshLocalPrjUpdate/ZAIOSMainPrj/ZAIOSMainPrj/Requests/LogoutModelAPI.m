//
//  LogoutModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LogoutModelAPI.h"

@implementation LogoutModelRequest
@end

@implementation LogoutModelResponse
@end

@implementation LogoutModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[LogoutModelRequest alloc] initWithEndpoint:@"papa/user/logout" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [LogoutModelResponse class];
    }
    return self;
}

@end