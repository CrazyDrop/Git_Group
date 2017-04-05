//
//  TimeRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "TimeRefreshManager.h"

#import "PWDTimeManager.h"
#import "LocalTimingRefreshManager.h"
#import "LocationTimeRefreshManager.h"
#import "RecorderTimeRefreshManager.h"
#import "OpenTimesRefreshManager.h"
#import "RemoteNTFRefreshManager.h"
#import "LeanCloudRefreshManager.h"

@interface TimeRefreshManager()
{
    NSTimer *refreshTimer;//刷新新消息数用的定时器
}
@end

@implementation TimeRefreshManager

+(instancetype)sharedInstance
{
    static TimeRefreshManager *shareTimeRefreshManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareTimeRefreshManagerInstance = [[[self class] alloc] init];
    });
    return shareTimeRefreshManagerInstance;
}

-(id)init
{
    self =[super init];
    if(self){
        self.userDefaultIndentifyStr = @"testDefault";
        self.functionInterval = 60*5;
        self.refreshInterval = 60;
    }
    return self;
}

-(void)localSaveRefreshTime:(NSDate *)date
{
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    NSString * indentify = self.userDefaultIndentifyStr ;
    
    if(!date)
    {
        [stand removeObjectForKey:indentify];
    }else{
        NSTimeInterval lastUpdateTime=[date timeIntervalSince1970];
        [stand setObject:[NSNumber numberWithDouble:lastUpdateTime]
                  forKey:indentify];
    }
    [stand synchronize];
}
-(BOOL)localTimeNeedRefreshCheck
{
    NSString * indentify = self.userDefaultIndentifyStr ;
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    NSTimeInterval lastTime=[stand doubleForKey:indentify];
    if (lastTime==NSNotFound||lastTime<1) return YES;
    
    //刷新和运行时间一致，不进行判定
    NSInteger number = self.functionInterval;
    if(number==self.refreshInterval) return YES;
    
    //时间计算
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:lastTime+number];
    NSDate * now = [NSDate date];
    NSComparisonResult result = [now compare:date];
    
    return result == NSOrderedDescending;
    //如果date是过去的时间，则需要刷新
}
-(void)refreshToken:(id)sender
{
    //时间检查
    if(![self localTimeNeedRefreshCheck])
        return;
    
    //启动
    if(self.funcBlock)
    {
        self.funcBlock();
    }
}


//设定起始时间，并开始
-(void)saveCurrentAndStartAutoRefresh
{
    //本地更新时间记录
    //首次检查时，是需要进行定位的
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:-10-self.functionInterval];
    [self localSaveRefreshTime:date];
    
    [self startAutoRefresh];
}

//清空起始时间，并结束
-(void)endAutoRefreshAndClearTime{
    //清空更新时间记录
    [self localSaveRefreshTime:nil];

    [self stopAutoRefresh];
    
}


//到达时间刷新
-(void)startAutoRefresh
{
    NSTimeInterval timeCount = self.refreshInterval;
    //获取当前存储时间
    if (refreshTimer&&[refreshTimer isValid])
    {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
    
    refreshTimer=[NSTimer scheduledTimerWithTimeInterval:timeCount target:self selector:@selector(refreshToken:) userInfo:nil repeats:true];
    [refreshTimer fire];
}

//关闭时间刷新
-(void)stopAutoRefresh
{
    
    if (refreshTimer&&[refreshTimer isValid])
    {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}

-(void)finishFunctionAndSaveCurrentTime{
    //进行时间更新
    NSDate * date = [NSDate date];
    [self localSaveRefreshTime:date];
}

//关闭所有倒计时
+(void)stopCurrentAllRefreshManager
{
    [[PWDTimeManager sharedInstance] endAutoRefreshAndClearTime];
    [[LocalTimingRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    [[LocationTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    [[RecorderTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    [[OpenTimesRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    [[RemoteNTFRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    [[LeanCloudRefreshManager sharedInstance] endAutoRefreshAndClearTime];
}
-(BOOL)isRefreshing
{
    if(!refreshTimer) return NO;
    return refreshTimer.valid;
}


@end
