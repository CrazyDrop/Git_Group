//
//  ZAOAFHTTPRequestOperationManager.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "ZAIWebRequestManager.h"

@class ZAIWebRequestTask;

@interface ZAIWebRequestOperationManager : AFHTTPRequestOperationManager <ZAIWebRequestManagerProtocol>

@end
