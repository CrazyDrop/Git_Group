//
//  ZWPanicRefreshManager.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicRefreshManager.h"

@implementation ZWPanicRefreshManager

+(instancetype)sharedInstance
{
    static ZWPanicRefreshManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}





@end
