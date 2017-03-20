//
//  ZAIWebRequestKernel.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/17.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestCommon.h"

@interface ZAIWebRequestKernel : NSObject

/*
 核心数据，用户输入，用户自定义参数，用于异步api结果处理。
 */
#pragma mark - userInput不经过server直接回传
@property (nonatomic, strong)NSDictionary* userInput;

#pragma mark - 输出方式
@property (nonatomic, assign)ZAIWebRequestApiOutputType apiOutputType;

#pragma mark - 以下对应两种种输出方式

#pragma mark - 使用block处理api结果，适用于只使用一次，处理方式简单的api
@property (nonatomic, copy)outputHandler apiBlockOutputHandler;

#pragma mark - 使用通知传递api处理结果，适用于使用多次，逻辑复杂的api
@property (nonatomic, retain)NSString *apiNotificationName;

@end
