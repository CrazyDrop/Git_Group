//
//  ZAHTTPApi.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "STIHTTPNetwork.h"
#import "ZAHTTPRequest.h"
#import "ZAHTTPResponse.h"

@interface ZAHTTPApi : STIHTTPApi

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@end
