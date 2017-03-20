//
//  WarnTimingModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "WarnTimingModelAPI.h"

@implementation WarnTimingModelResponseDetail
@synthesize id;
@end

@implementation WarnTimingModelRequest

@end

@implementation WarnTimingModelResponse
@synthesize returnData;
@end



@implementation WarnTimingModelAPI
@synthesize req;
@synthesize resp;


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[WarnTimingModelRequest alloc] initWithEndpoint:@"papa/warning/createWarning" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [WarnTimingModelResponse class];
    }
    return self;
}

@end

