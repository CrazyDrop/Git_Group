//
//  ZALocationModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationModelAPI.h"
@implementation ZALocationModelRequest

@end

@implementation ZALocationModelResponse

@end




@implementation ZALocationModelAPI
@synthesize req;
@synthesize resp;


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZALocationModelRequest alloc] initWithEndpoint:@"papa/location/uploadLocation" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZALocationModelResponse class];
    }
    return self;
}


@end
