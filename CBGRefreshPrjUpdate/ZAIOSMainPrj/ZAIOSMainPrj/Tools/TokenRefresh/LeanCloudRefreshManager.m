//
//  LeanCloudRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/1.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "LeanCloudRefreshManager.h"

@implementation LeanCloudRefreshManager

+(instancetype)sharedInstance
{
    static LeanCloudRefreshManager *shareLeanCloudManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareLeanCloudManagerInstance = [[[self class] alloc] init];
    });
    return shareLeanCloudManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        //        __weak PWDTimeManager * weakSelf = self;
        self.userDefaultIndentifyStr = @"TimeRefreshManager_LeanCloud_Feedback";
        self.refreshInterval = 10;
        self.functionInterval = 10;
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
