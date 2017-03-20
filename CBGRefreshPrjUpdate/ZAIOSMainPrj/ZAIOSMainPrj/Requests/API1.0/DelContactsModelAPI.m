//
//  DelContactsModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DelContactsModelAPI.h"
@implementation DelContactsModelRequest

@end

@implementation DelContactsModelResponse

@end

@implementation DelContactsModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[DelContactsModelRequest alloc] initWithEndpoint:@"papa/contact/deleteContact" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [DelContactsModelResponse class];
    }
    return self;
}
-(void)setContanctId:(NSString *)contanctId
{
    _contanctId = [contanctId copy];
    
    NSString * shortUrl = @"papa/contact/deleteContact/";
    if(contanctId)
    {
        NSString * cId = self.contanctId;
        shortUrl = [shortUrl stringByAppendingString:cId?:@""];
    }
    //修改req
    self.req = [[DelContactsModelRequest alloc] initWithEndpoint:shortUrl method:STIHTTPRequestMethodPost];
    self.req.responseClass = [DelContactsModelResponse class];
}


@end
