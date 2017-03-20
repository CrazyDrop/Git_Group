//
//  ZALocalNotificationManager.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/7/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//本地通知管理中心
//处理本地通知的创建、取消
//主要控制
typedef enum : NSUInteger {
    ZALocalNotificationType_WarnNotice,     //预警提示，包含两种
    ZALocalNotificationType_TelInterrupt,   //电话打断提醒
    ZALocalNotificationType_CloseNotice,    //强杀提醒
    ZALocalNotificationType_RemindNotice      //定时唤起提醒
} ZALocalNotificationType;

@interface ZALocalNotificationManager : NSObject

+ (instancetype)sharedInstance;

//启动事件方法
-(void)startBackgroundTimerWakeUp;

-(void)startLocalNotificationWithType:(ZALocalNotificationType)type delaySecond:(NSTimeInterval)second;

-(void)cancelLocalNotificationWithType:(ZALocalNotificationType)type;

-(void)cancelPreVersionLocalNotification;

//返回值为NSNOTFOUND时，标识不需要启动
-(NSTimeInterval)firstNoticeForWakeupForCurrent;

@end
