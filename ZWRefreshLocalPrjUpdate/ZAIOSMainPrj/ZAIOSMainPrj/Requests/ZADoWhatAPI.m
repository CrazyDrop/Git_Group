//
//  ZADoWhatAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/6.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZADoWhatAPI.h"

@implementation ZADoWhatModelRequest
@synthesize warningId;
@synthesize whattodo;
@end

@implementation ZADoWhatModelResponse
@end

@implementation ZADoWhatAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZADoWhatModelRequest alloc] initWithEndpoint:@"papa/warning/whattodo" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZADoWhatModelResponse class];
    }
    return self;
}

@end

