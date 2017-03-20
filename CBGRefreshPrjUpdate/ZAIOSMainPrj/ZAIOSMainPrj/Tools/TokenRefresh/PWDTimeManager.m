//
//  PWDTimeManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/23.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "PWDTimeManager.h"

@interface PWDTimeManager ()
{
    
}
@end

@implementation PWDTimeManager

+(instancetype)sharedInstance
{
    static PWDTimeManager *sharePWDTimeManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharePWDTimeManagerInstance = [[[self class] alloc] init];
    });
    return sharePWDTimeManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self)
    {
//        __weak PWDTimeManager * weakSelf = self;
        self.userDefaultIndentifyStr = @"TimeRefreshManager_Local_PWD";
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
