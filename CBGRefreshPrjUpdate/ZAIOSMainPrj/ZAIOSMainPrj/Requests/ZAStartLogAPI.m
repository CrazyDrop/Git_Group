//
//  ZAStartLogAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/13.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartLogAPI.h"

@implementation ZAStartLogRequest

@end

@implementation ZAStartLogResponse
@end

@implementation ZAStartLogAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZAStartLogRequest alloc] initWithEndpoint:@"papa/ad/appBootLogged" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAStartLogResponse class];
    }
    return self;
}

@end