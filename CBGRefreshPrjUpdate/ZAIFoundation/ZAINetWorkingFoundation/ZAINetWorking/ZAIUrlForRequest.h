//
//  ZAOUrlForRemoteData.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/15.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestCommon.h"

@interface ZAIUrlForRequest : NSObject

+ (NSString *)urlForUserRegisterWithType:(ZAIUrlType)type;

+ (NSString *)urlForZATestAPIWithType:(ZAIUrlType)type;

@end
