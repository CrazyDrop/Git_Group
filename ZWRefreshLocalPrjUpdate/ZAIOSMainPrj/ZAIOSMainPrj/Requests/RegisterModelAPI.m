//
//  RegisterModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "RegisterModelAPI.h"
@implementation RegisterModelResponseDetail
@synthesize token;
@end
@implementation RegisterModelRequest
//@synthesize  username;
//@synthesize  password;
@synthesize  mobile;
@synthesize  vcode;
@end

@implementation RegisterModelResponse
@synthesize returnData;
@end

@implementation RegisterModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[RegisterModelRequest alloc] initWithEndpoint:@"papa/user/register" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [RegisterModelResponse class];
    }
    return self;
}

@end