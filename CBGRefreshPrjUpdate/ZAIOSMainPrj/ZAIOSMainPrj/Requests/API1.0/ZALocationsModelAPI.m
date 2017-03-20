//
//  ZALocationsModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationsModelAPI.h"
@implementation ZALocationsModelRequest

@end

@implementation ZALocationsModelResponse

@end




@implementation ZALocationsModelAPI
@synthesize req;
@synthesize resp;


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZALocationsModelRequest alloc] initWithEndpoint:@"papa/location/uploadLocations" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZALocationsModelResponse class];
    }
    return self;
}


@end
