//
//  ZWProxyRefreshManager.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWProxyRefreshManager.h"

@implementation ZWProxyRefreshManager

+(instancetype)sharedInstance
{
    static ZWProxyRefreshManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}



@end
