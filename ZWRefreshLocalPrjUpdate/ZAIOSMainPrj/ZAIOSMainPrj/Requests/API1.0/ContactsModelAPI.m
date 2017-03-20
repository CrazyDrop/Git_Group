//
//  ContactsModelApi.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ContactsModelAPI.h"

@implementation ContactsModelRequest

@end

@implementation ContactsModelResponse

@end

@implementation ContactsModelAPI
@synthesize req;
@synthesize resp;


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ContactsModelRequest alloc] initWithEndpoint:@"papa/contact/addContact" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ContactsModelResponse class];
    }
    return self;
}

-(void)setContanctId:(NSString *)contanctId
{
    _contanctId = [contanctId copy];
    

    NSString * shortUrl = @"papa/contact/addContact";
    if(contanctId)
    {
        shortUrl = @"papa/contact/updateContact/";
        NSString * cId = self.contanctId;
        shortUrl = [shortUrl stringByAppendingString:cId?:@""];
    }
    //修改req
    self.req = [[ContactsModelRequest alloc] initWithEndpoint:shortUrl method:STIHTTPRequestMethodPost];
    self.req.responseClass = [ContactsModelResponse class];

}





@end
