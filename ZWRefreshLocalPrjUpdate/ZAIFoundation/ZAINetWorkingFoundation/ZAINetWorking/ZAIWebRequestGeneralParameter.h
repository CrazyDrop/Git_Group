//
//  ZAOWebRequestGeneralParameter.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/15.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZAIWebRequestGeneralParameter : NSObject

+ (NSString *)getDeviceVersion;
+ (NSString *)currentDeviceIdentifer;
+ (NSString *)platformString;
+ (NSString *)currentAppBundleShortVersion;

@end
