//
//  ZAIPostNotificationOnMainThread.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZAIPostNotificationOnMainThread : NSObject

+ (void)postNotification:(NSNotification *)aNotification;
+ (void)postNotificationAsynchronously:(NSNotification *)aNotification;

@end
