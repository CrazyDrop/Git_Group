//
//  ZAORequestWebData.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestCollector.h"
#import "ZAIWebRequestCommon.h"

@class ZAIWebRequestTask;

@interface ZAIWebRequestAPI : NSObject

+ (void) cancelRequest:(ZAIRequestID)requestId;

+ (ZAIRequestID)requestWebDataWithTask:(ZAIWebRequestTask*)task;

+ (ZAIRequestID)requestWebDatawithBlock:(outputHandler)outputBlock method:(ZAIWebRequestMethod)methodType url:(NSString *)urlString parameters:(NSDictionary*)parameters APIInput:(NSDictionary *)input;

+ (ZAIRequestID)requestWebDataWithNotification:(NSString *)message method:(ZAIWebRequestMethod)methodType url:(NSString *)urlString parameters:(NSDictionary*)parameters APIInput:(NSDictionary *)input;

@end
