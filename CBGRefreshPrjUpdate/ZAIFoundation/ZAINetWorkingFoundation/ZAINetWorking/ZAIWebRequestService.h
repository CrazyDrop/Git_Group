//
//  ZAOWebAPIRequestService.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestCommon.h"
#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestCollector.h"

@interface ZAIWebRequestService : NSObject

+ (ZAIWebRequestService *)shareService;

- (void) cancelAPI : (ZAIRequestID) apiUID;

- (ZAIRequestID) requestApiAsynchronous : (ZAIWebRequestTask *) kernel;

@end
