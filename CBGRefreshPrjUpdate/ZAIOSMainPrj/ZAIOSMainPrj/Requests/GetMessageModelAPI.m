//
//  GetMessageModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetMessageModelAPI.h"

@implementation GetMessageModelRequest
@synthesize mobile;
@end

@implementation GetMessageModelResponse

@end

@implementation GetMessageModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[GetMessageModelRequest alloc] initWithEndpoint:@"papa/user/sendCaptcha" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [GetMessageModelResponse class];
    }
    return self;
}



@end