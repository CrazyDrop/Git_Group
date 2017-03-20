//
//  ModifyUserInfoModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ModifyUserInfoModelAPI.h"

@implementation ModifyUserInfoModelRequest
@synthesize username;
@synthesize password;
@end

@implementation ModifyUserInfoModelResponse
@end

@implementation ModifyUserInfoModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ModifyUserInfoModelRequest alloc] initWithEndpoint:@"papa/user/modifyUser" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ModifyUserInfoModelResponse class];
    }
    return self;
}

@end
