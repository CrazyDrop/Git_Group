//
//  RemoteNTFRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/26.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "RemoteNTFRefreshManager.h"

@implementation RemoteNTFRefreshManager

+(instancetype)sharedInstance
{
    static RemoteNTFRefreshManager *shareRemoteNTFTimeManagerInstance = nil;
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
        self.userDefaultIndentifyStr = @"TimeRefreshManager_Remote_Notification";
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
//-(BOOL)localTimeNeedRefreshCheck
//{
//    NSString * indentify = self.userDefaultIndentifyStr ;
//    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
//    NSTimeInterval lastTime=[stand doubleForKey:indentify];
//    if (lastTime==NSNotFound||lastTime<0.1) return YES;
//    
//    //刷新和运行时间一致，不进行判定
//    NSInteger number = self.functionInterval;
//    if(number==self.refreshInterval) return YES;
//    
//    //时间计算
//    NSDate * date = [NSDate dateWithTimeIntervalSince1970:lastTime+number];
//    NSDate * now = [NSDate date];
//    NSComparisonResult result = [now compare:date];
//    
//    return result == NSOrderedDescending;
//    //如果date是过去的时间，则需要刷新
//}

@end
