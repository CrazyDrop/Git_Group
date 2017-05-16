//
//  PanicRefreshManager.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "PanicRefreshManager.h"

@implementation PanicRefreshManager
+(instancetype)sharedInstance
{
    static PanicRefreshManager *shareRemoteNTFTimeManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareRemoteNTFTimeManagerInstance = [[[self class] alloc] init];
    });
    return shareRemoteNTFTimeManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        //        __weak PWDTimeManager * weakSelf = self;
        self.userDefaultIndentifyStr = @"PanicRefreshManager_Panic_Notification";
        self.refreshInterval = 5;//高频刷新，10s刷新一次
        self.functionInterval = 5;
        
        [self endAutoRefreshAndClearTime];
    }
    return self;
}

@end
