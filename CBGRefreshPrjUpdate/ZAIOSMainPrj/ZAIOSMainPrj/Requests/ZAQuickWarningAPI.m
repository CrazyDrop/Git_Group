//
//  ZAQuickWarningAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAQuickWarningAPI.h"

@implementation ZAQuickWarningModelResponseDetail
@synthesize id;
@end

@implementation ZAQuickWarningRequest
@synthesize scene;
@synthesize duration;
@end

@implementation ZAQuickWarningResponse
@synthesize returnData;
@end

@implementation ZAQuickWarningAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZAQuickWarningRequest alloc] initWithEndpoint:@"papa/warning/triggerWarning" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAQuickWarningResponse class];
    }
    return self;
}

@end