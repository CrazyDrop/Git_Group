//
//  TokenRefreshManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//


//功能，实现token的刷新
//风险(暂忽略)  响应某些事件时 (需要用到token)   此时刷新token请求已经发送 但结果未返回 服务器端有可能收到刷新之前的token
@interface TokenRefreshManager : NSObject


//用户登录，用于时间计算
-(void)userLoginSuccess;

//用户登出
-(void)userLogout;


//token刷新接口
//到达前台，启动
-(void)startAutoRefresh;

//进入后台，关闭
-(void)stopAutoRefresh;







@end
