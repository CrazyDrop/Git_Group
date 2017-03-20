//
//  PaPaUserInfoModelApi.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "PaPaUserInfoModelAPI.h"
@implementation PaPaUserInfoModelRequest

@end

@implementation PaPaUserInfoModelResponse

@end



@implementation PaPaUserInfoModelAPI
@synthesize req;
@synthesize resp;


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[PaPaUserInfoModelRequest alloc] initWithEndpoint:@"papa/user/addUser" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [PaPaUserInfoModelResponse class];
    }
    return self;
}

@end
