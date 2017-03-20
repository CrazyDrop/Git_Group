//
//  GetCheckNumAPI.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetCheckNumAPI.h"

@implementation GetCheckNumReqeust

- (NSString *)createSign
{
    if(self.phoneNo)
        return [ZAHTTPRequest createSignByPhoneNum:self.phoneNo];
    return @"";
}

@end

@implementation GetCheckNumResponse


@end


@implementation GetCheckNumAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[GetCheckNumReqeust alloc] initWithEndpoint:@"/app/user/sendCaptcha" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [GetCheckNumResponse class];
    }
    return self;
}

@end
