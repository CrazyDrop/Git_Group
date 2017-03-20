//
//  WarningModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "WarningModelAPI.h"

@implementation WarningModelRequest

@end

@implementation WarningModelResponse

@end



@implementation WarningModelAPI
@synthesize req;
@synthesize resp;


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[WarningModelRequest alloc] initWithEndpoint:@"papa/warning/checkWarning" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [WarningModelResponse class];
        self.timeoutInterval = 20;
    }
    return self;
}

-(void)setType:(WarningModelTYPE)type
{
    _type = type;
    
    NSString * shortUrl = @"papa/warning/checkWarning";
    
    switch (type) {
        case WarningModel_TYPE_START:
        {
            shortUrl = @"papa/warning/runWarning";
        }
            break;
        case WarningModel_TYPE_STOP:
        {
            shortUrl = @"papa/warning/cancelWarning";
        }
            break;
        default:
            break;
    }
    
//    if(type!=WarningModel_TYPE_CHECK)
    {
        NSString * cId = self.timingId;
        shortUrl = [shortUrl stringByAppendingString:cId?:@""];
    }
    
    //修改req
    self.req = [[WarningModelRequest alloc] initWithEndpoint:shortUrl method:STIHTTPRequestMethodPost];
    self.req.responseClass = [WarningModelResponse class];

    
}



@end
