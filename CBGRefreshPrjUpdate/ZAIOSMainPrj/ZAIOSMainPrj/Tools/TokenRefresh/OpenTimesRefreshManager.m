//
//  OpenTimesRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "OpenTimesRefreshManager.h"

@implementation OpenTimesRefreshManager

+(instancetype)sharedInstance
{
    static OpenTimesRefreshManager *shareOpenTimesManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareOpenTimesManagerInstance = [[[self class] alloc] init];
    });
    return shareOpenTimesManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        //        __weak PWDTimeManager * weakSelf = self;
        self.userDefaultIndentifyStr = @"TimeRefreshManager_Local_OpenTimes";
        self.refreshInterval = 60;
        self.functionInterval = 60*2;
        //        self.funcBlock = ^(void)
        //        {
        //            //进行时间检查修改
        //
        //
        //
        //        };
        
        [self endAutoRefreshAndClearTime];
    }
    return self;
}

@end
