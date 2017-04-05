//
//  TokenRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "TokenRefreshManager.h"

//每隔10分钟刷新
#define ZATokenRefreshTimeInterval  (10*60)//消息的刷新提醒时间
#define ZATimerCheckInterval        (60)   //定时器检查时间间隔
//检查更新机制  每分钟进行检查  没10分钟进行更新
//最近一次的token刷新
#define USERDEFAULT_UPLDATE_TIME_TOKEN_REFRESH  @"USERDEFAULT_UPLDATE_TIME_TOKEN_REFRESH"

@interface TokenRefreshManager ()
{
//    RefreshTokenModel * _refreshModel;
    NSTimer *refreshTimer;//刷新新消息数用的定时器
    NSLock * lock;
}
@end

@implementation TokenRefreshManager

-(id)init
{
    self = [super init];
    if(self)
    {
        lock = [[NSLock alloc] init];
    }
    return self;
}
+(instancetype)sharedInstance
{
    static TokenRefreshManager *shareTokenRefreshManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareTokenRefreshManagerInstance = [[[self class] alloc] init];
    });
    return shareTokenRefreshManagerInstance;
}

//用户登录，用于时间计算
-(void)userLoginSuccess
{
    //本地更新时间记录
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:-60];
    [self localSaveRefreshTime:date];
    
    [self startAutoRefresh];
}

//用户登出
-(void)userLogout
{
    //清空更新时间记录
    [self localSaveRefreshTime:nil];

    [self stopAutoRefresh];
}

-(void)localSaveRefreshTime:(NSDate *)date
{
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    if(!date)
    {
        [stand removeObjectForKey:USERDEFAULT_UPLDATE_TIME_TOKEN_REFRESH];
    }else{
        NSTimeInterval lastUpdateTime=[date timeIntervalSince1970];
        [stand setObject:[NSNumber numberWithDouble:lastUpdateTime]
                                                 forKey:USERDEFAULT_UPLDATE_TIME_TOKEN_REFRESH];
    }
    [stand synchronize];
}

#pragma mark RegisterModel
handleSignal( RefreshTokenModel, requestLoading )
{
    
}

handleSignal( RefreshTokenModel, requestLoaded )
{
    //成功后model有保存
//    RefreshTokenResponse * resp = signal.object;
//    if(resp&&[resp.returnCode intValue] == HTTPReturnSuccess)
//    {
//        //进行时间更新
//        NSDate * date = [NSDate date];
//        [self localSaveRefreshTime:date];
//    }
}

handleSignal( RefreshTokenModel, requestError )
{
    //当请求错误时，如何处理
    //暂不处理
    
}
-(BOOL)localTimeNeedRefreshCheck
{
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    NSTimeInterval lastTime=[stand doubleForKey:USERDEFAULT_UPLDATE_TIME_TOKEN_REFRESH];
    if (lastTime==NSNotFound||lastTime<1) return YES;
    
    //时间计算
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:lastTime+ZATokenRefreshTimeInterval];
    NSDate * now = [NSDate date];
//    NSTimeInterval count = [date timeIntervalSinceDate:now];
    NSComparisonResult result = [now compare:date];
    return result == NSOrderedDescending;
}
-(void)refreshToken:(id)sender
{
    //时间检查
    if(![self localTimeNeedRefreshCheck])
        return;
    
//    RefreshTokenModel * model = _refreshModel;
//    if(!model)
//    {
//        model = [[RefreshTokenModel alloc] init];
//        [model addSignalResponder:self];
//        _refreshModel = model;
//    }
//    [model sendRequest];
}


//到达前台，启动
-(void)startAutoRefresh
{
//    AccountManager * manager = [AccountManager sharedInstance] ;
//    if(![manager hasLogedIn]) return;
    
    //获取当前存储时间
    if (refreshTimer&&[refreshTimer isValid])
    {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
    
    refreshTimer=[NSTimer scheduledTimerWithTimeInterval:ZATimerCheckInterval target:self selector:@selector(refreshToken:) userInfo:nil repeats:true];
    [refreshTimer fire];
    
}

//进入后台，关闭
-(void)stopAutoRefresh
{
    if (refreshTimer&&[refreshTimer isValid])
    {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
    
}


@end
