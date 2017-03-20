//
//  ZAContactTellAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/17.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactTellAPI.h"

@implementation ZAContactTellRequest


@end

@implementation ZAContactTellResponse


@end

@implementation ZAContactTellAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZAContactTellRequest alloc] initWithEndpoint:@"papa/contact/tellContact" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAContactTellResponse class];
    }
    return self;
}
- (instancetype)initWithContactedId:(NSString *)idStr
{
    self = [self init];
    if(self)
    {
        if(idStr)
        {
            NSString * total = [NSString stringWithFormat:@"papa/contact/tellContact/%@",idStr];
            self.req = [[ZAContactTellRequest alloc] initWithEndpoint:total method:STIHTTPRequestMethodPost];
            self.req.responseClass = [ZAContactTellResponse class];
            
        }
    }
    return self;
}


@end
