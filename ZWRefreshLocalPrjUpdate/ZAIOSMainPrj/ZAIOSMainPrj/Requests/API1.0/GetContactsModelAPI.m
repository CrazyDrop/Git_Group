//
//  GetContactsModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetContactsModelAPI.h"

@implementation GetContactsModelRequest

@end

@implementation GetContactsModelResponse

@end

@implementation GetContactsModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[GetContactsModelRequest alloc] initWithEndpoint:@"papa/contact/getContacts" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [GetContactsModelResponse class];
    }
    return self;
}



@end

