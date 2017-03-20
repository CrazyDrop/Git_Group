//
//  ZAORequestCollector.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestCommon.h"
#import "ZAIWebRequestProtocol.h"

@interface ZAIWebRequestCollector : NSObject

- (ZAIRequestID) insertRequest : (id<ZAIWebRequestProtocol>) request;
- (ZAIRequestID) findRequest : (id<ZAIWebRequestProtocol>) request;
- (id<ZAIWebRequestProtocol>) requestForUid : (ZAIRequestID) uid;

- (bool) removeRequestWithUid : (ZAIRequestID) uid;
- (bool) removeRequest : (id<ZAIWebRequestProtocol>) request;

@end
