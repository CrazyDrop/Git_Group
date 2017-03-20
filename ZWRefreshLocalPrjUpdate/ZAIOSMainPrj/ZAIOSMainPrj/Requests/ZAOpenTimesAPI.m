//
//  ZAOpenTimesAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAOpenTimesAPI.h"

@implementation ZAOpenTimesResponseDetail

@synthesize opentimes;

@end

@implementation ZAOpenTimesRequest
//@synthesize warnId;
@end

@implementation ZAOpenTimesResponse
@synthesize returnData;
@end

@implementation ZAOpenTimesAPI
@synthesize req;
@synthesize resp;

//先设定id,后设定type   否则无法删除
- (instancetype)initWithWarnTimingId:(NSString *)idStr
{
    self = [super init];
    if(self)
    {
        NSString * timeId = @"papa/share/openTimesCount";
        if(idStr && [idStr length]>0)
        {
            timeId = [timeId stringByAppendingPathComponent:idStr];
        }
        
        self.req = [[ZAOpenTimesRequest alloc] initWithEndpoint:timeId method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAOpenTimesResponse class];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZAOpenTimesRequest alloc] initWithEndpoint:@"papa/share/openTimesCount" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAOpenTimesResponse class];
    }
    return self;
}

@end
