//
//  ZAHTTPClient.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIHTTPSessionManager.h"

@interface ZAHTTPClient : NSObject

+ (AFSecurityPolicy *)customSecurityPolicy;

+ (NSURLCredential *)customCredential;

@end

@interface ZAHTTPSessionManager : STIHTTPSessionManager

@end

@interface ZAHTTPRequestManager : STIHTTPRequestManager

@end