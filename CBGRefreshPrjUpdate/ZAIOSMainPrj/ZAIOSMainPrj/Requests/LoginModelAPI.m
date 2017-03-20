//
//  LoginModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LoginModelAPI.h"

@implementation LoginModelResponseDetail
@synthesize token;
@end


@implementation LoginModelRequest
@synthesize mobile;
@synthesize vcode;
@end

@implementation LoginModelResponse
@synthesize returnData;
@end

@implementation LoginModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[LoginModelRequest alloc] initWithEndpoint:@"papa/user/login" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [LoginModelResponse class];
    }
    return self;
}

@end

