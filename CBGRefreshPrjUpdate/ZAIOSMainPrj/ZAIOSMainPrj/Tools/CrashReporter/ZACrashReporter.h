//
//  ZACrashReporter.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZACrashReporter : NSObject

- (void)checkCrashLog;

+ (ZACrashReporter *)sharedInstance;

@end
