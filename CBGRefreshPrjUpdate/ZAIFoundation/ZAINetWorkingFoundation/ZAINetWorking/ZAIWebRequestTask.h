//
//  ZAOWebRequestAPI.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestCommon.h"
#import "ZAIWebRequestProtocol.h"

@class ZAIWebRequestTask;
@class ZAIWebRequestKernel;
@class ZAIWebRequestCollector;

@interface ZAIWebRequestTask : NSObject<ZAIWebRequestProtocol>

//核心数据
@property (nonatomic, strong)ZAIWebRequestKernel *kernel;

#pragma mark - 请求方法
@property (nonatomic, assign)ZAIWebRequestMethod requestMethod;

#pragma mark - 调用的域名
@property (nonatomic, retain)NSString* requestUrl;

#pragma mark - url参数
@property (nonatomic, strong)id parameters;

#pragma mark - sign
@property (nonatomic, retain)NSString* sign;

#pragma mark - request Message
@property (nonatomic, retain)id request;

#pragma mark - ************以上为配置一个api必须实现的属性和方法**************
- (id) initWithParam:(NSDictionary *)apiInfos;

@end
