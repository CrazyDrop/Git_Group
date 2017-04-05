//
//  CancelWarningRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "CancelWarningRefreshManager.h"

@implementation CancelWarningRefreshManager

+(instancetype)sharedInstance
{
    static CancelWarningRefreshManager *shareCancelWarningManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareCancelWarningManagerInstance = [[[self class] alloc] init];
    });
    return shareCancelWarningManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        //        __weak PWDTimeManager * weakSelf = self;
        self.userDefaultIndentifyStr = @"TimeRefreshManager_Local_CancelWarning";
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
