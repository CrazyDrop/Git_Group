//
//  GetUserInfoModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetUserInfoModelAPI.h"

@implementation GetUserInfoModelRequest

@end

@implementation GetUserInfoModelResponse
@synthesize returnData;
@end

@implementation GetUserInfoModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[GetUserInfoModelRequest alloc] initWithEndpoint:@"papa/user/getInfo" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [GetUserInfoModelResponse class];
    }
    return self;
}

@end
