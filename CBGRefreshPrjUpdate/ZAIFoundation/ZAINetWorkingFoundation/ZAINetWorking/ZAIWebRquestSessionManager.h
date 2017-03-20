//
//  ZAOHTTPSessionManager.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/12.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ZAIWebRequestManager.h"

@class ZAIWebRequestTask;

@interface ZAIWebRquestSessionManager : AFHTTPSessionManager <ZAIWebRequestManagerProtocol>

@end
