//
//  ZAIconUploadModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/10.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAIconUploadModelAPI.h"

@implementation ZAIconUploadModelAPI
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZAUploadModelRequest alloc] initWithEndpoint:@"papa/user/modifyIcon" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAUploadModelResponse class];
    }
    return self;
}

@end
