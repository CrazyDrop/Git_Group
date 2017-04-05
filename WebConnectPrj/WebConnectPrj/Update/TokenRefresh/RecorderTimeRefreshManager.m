//
//  RecorderTimeRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/11.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "RecorderTimeRefreshManager.h"
//#import "ZARecorderManager.h"
@implementation RecorderTimeRefreshManager
+(instancetype)sharedInstance
{
    static RecorderTimeRefreshManager *sharePWDTimeManagerInstance = nil;
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
        self.userDefaultIndentifyStr = @"TimeRefreshManager_Local_Recorder";
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

////清空起始时间，并结束
//-(void)endAutoRefreshAndClearTime
//{
//    [super endAutoRefreshAndClearTime];
//    
//    //停止录音，清空操作
//    ZARecorderManager * manager = [ZARecorderManager sharedInstanceManager];
//    manager.DoneRecorderAndFinishedExchangeBlock = nil;
//    [manager stopRecorder];
//}
@end
