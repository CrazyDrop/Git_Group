//
//  ZAIWebRequestManager.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZAIWebRequestTask;

@protocol ZAIWebRequestManagerProtocol <NSObject>

@required
+ (instancetype)sharedClient;
-(void)startRequestWithTask:(ZAIWebRequestTask *)task;
-(void)cancelWithTask:(ZAIWebRequestTask*) task;
@end

@interface ZAIWebRequestManager : NSObject

+(id<ZAIWebRequestManagerProtocol>)shareClient;

@end
