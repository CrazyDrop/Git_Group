//
//  ZALocalNotificationManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/7/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocalNotificationManager.h"
#import "ZWSystemTotalRequestModel.h"
#import "ZWSellOthersListClearModel.h"
@interface ZALocalNotificationManager()
{
    NSTimer * wakeTimer;
    BaseRequestModel * _sysRequestModel;
}
@end

@implementation ZALocalNotificationManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static ZALocalNotificationManager  * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}
-(NSString *)notificationTypeIdentifierForType:(ZALocalNotificationType)type
{
    NSString * identifier = nil;
    switch (type) {
        case ZALocalNotificationType_WarnNotice:
            identifier = @"ZALocalNotificationType_WarnNotice";
            break;
        case ZALocalNotificationType_RemindNotice:
            identifier = @"ZALocalNotificationType_RemindNotice";
            break;
        case ZALocalNotificationType_TelInterrupt:
            identifier = @"ZALocalNotificationType_TelInterrupt";
            break;
        case ZALocalNotificationType_CloseNotice:
            identifier = @"ZALocalNotificationType_CloseNotice";
            break;
        default:
            break;
    }
    return identifier;
}


-(void)startLocalNotificationWithType:(ZALocalNotificationType)type delaySecond:(NSTimeInterval)second
{
    NSMutableArray * notifications = [NSMutableArray array];
    NSString * typeIdentifier = [self notificationTypeIdentifierForType:type];
    switch (type)
    {
        case ZALocalNotificationType_CloseNotice:
        {
            second = 1;//特定值
//            手动杀掉APP提醒。防护中：怕怕已关闭，小怕仍将继续守护您的安全。未开启防护但有好友:关闭小怕将影响您与好友的位置共享，请重新开启怕怕。未开启防护无好友：无推送
            
            NSString * noticeStr = nil;
            ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
            WarnTimingModel * timeModel = total.timeModel;
            PaPaUserInfoModel * info = total.userInfo;
            
            if(noticeStr)
            {
                UILocalNotification * notification = [self createLocalNotificationWithTime:second
                                                                                       msg:noticeStr
                                                                         andTypeIdentifier:typeIdentifier];
                [notifications addObject:notification];
            }

        }
            break;
        case ZALocalNotificationType_TelInterrupt:
        {
            second = 3;//特定值
            UILocalNotification * notification = [self createLocalNotificationWithTime:second
                                                             msg:@"接打电话、微信QQ发送语音，导致怕怕语音求助失效，打开怕怕即可重新激活"
                                               andTypeIdentifier:typeIdentifier];
            [notifications addObject:notification];
        }
            break;
        case ZALocalNotificationType_RemindNotice:
        {
//            NSTimeInterval daysInterval = 60 * 60 * 24;
//            for (NSInteger index = 0; index < 30; index ++)
            {
                NSTimeInterval eveInterval = second;
                UILocalNotification * notification = [self createLocalNotificationWithTime:eveInterval
                                                                                       msg:@"主人主人，出门带上小怕呗，我会biubiubiu的发光保护你！"
                                                                         andTypeIdentifier:typeIdentifier];
                
                notification.repeatInterval = NSCalendarUnitDay;
                notification.repeatCalendar = [NSCalendar currentCalendar];
                notification.hasAction = NO;
                [notifications addObject:notification];
                
            }
        }
            break;
        case ZALocalNotificationType_WarnNotice:
        {
            //倒计时结束提醒
            UILocalNotification * notification2 = [self createLocalNotificationWithTime:second
                                                                                   msg:@"您启动的预警倒计时已经触发,如已安全请尽快关闭"
                                                                     andTypeIdentifier:typeIdentifier];
            [notifications addObject:notification2];
            
            
            //倒计时结束前3分钟提醒
            NSTimeInterval total = second - 60 * 3;
            if(total > 0)
            {
                UILocalNotification * notification = [self createLocalNotificationWithTime:total
                                                                                       msg:@"本次定时防护还有3分钟将启动预警，如已安全请结束防护。"
                                                                         andTypeIdentifier:typeIdentifier];
                [notifications addObject:notification];
            }
        }
            break;
        default:
            break;
    }
    
//    if(notifications && [notifications count]>0){
//        [[UIApplication sharedApplication] setScheduledLocalNotifications:notifications];
//    }
    //或者
    for (UILocalNotification * eve in notifications)
    {
        [[UIApplication sharedApplication] scheduleLocalNotification:eve];
    }
    
}

-(UILocalNotification *)createLocalNotificationWithTime:(NSTimeInterval)second
                                                    msg:(NSString *)msg
                                      andTypeIdentifier:(NSString *)identifier
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //设置本地通知的触发时间（如果要立即触发，无需设置），这里设置为20妙后
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:second];
    //设置本地通知的时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //设置通知的内容
    localNotification.alertBody = msg;
    //设置通知动作按钮的标题
    localNotification.alertAction = @"打开查看";
    //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setValue:identifier forKey:@"type"];
    localNotification.userInfo = infoDic;

    return localNotification;
}

-(void)cancelPreVersionLocalNotification
{
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotification  in array)
    {
        NSDictionary * dic = [localNotification userInfo];
        NSString * localId = [dic valueForKey:@"id"];
        if([localId isEqualToString:NSLOCAL_NOTIFICATION_IDENTIFIER]||[localId isEqualToString:NSLOCAL_NOTIFICATION_IDENTIFIER_BEFORE])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}


-(void)cancelLocalNotificationWithType:(ZALocalNotificationType)type
{
    NSString * typeIdentifier = [self notificationTypeIdentifierForType:type];
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotification  in array)
    {
        NSDictionary * dic = [localNotification userInfo];
        NSString * eveIdentifier = [dic valueForKey:@"type"];
        if([typeIdentifier isEqualToString:eveIdentifier])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

-(NSTimeInterval)firstNoticeForWakeupForCurrent
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    PaPaUserInfoModel * info = total.userInfo;
    NSString * status = @"1";
    if(status && [status integerValue] == 1)
    {
        NSString * dateString = @"08:00";
        if(!dateString) return NSNotFound;
        NSDateFormatter *dateFormatter = [NSDate format:@"HH:mm"];
        NSDate *wakeDate = [dateFormatter dateFromString:dateString];
        NSDate * current = [self currentDateForWakeup];
        
        NSTimeInterval count = [wakeDate timeIntervalSinceDate:current];
        if(count > 60)
        {
            count -= 60;
        }
        
        if(count < 0)
        {
            count += (60 * 60 * 24);
        }
        
        return count;
    }
    return  NSNotFound;
}
-(NSTimeInterval)wakeUpNoticeForWakeupWithWakeUpTime:(NSString *)time
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    PaPaUserInfoModel * info = total.userInfo;
    NSString * status = @"1";
    if(status && [status integerValue] == 1)
    {
        NSString * dateString = time;
        if(!dateString) return NSNotFound;
        NSDateFormatter *dateFormatter = [NSDate format:@"HH:mm"];
        NSDate *wakeDate = [dateFormatter dateFromString:dateString];
        NSDate * current = [self currentDateForWakeup];
        
        NSTimeInterval count = [wakeDate timeIntervalSinceDate:current];
        if(count > 60)
        {
            count -= 60;
        }
        
        if(count < 0)
        {
            count += (60 * 60 * 24);
        }
        
        return count;
    }
    return  NSNotFound;
}
-(NSDate * )currentDateForWakeup
{
    NSDate * currentDate = [NSDate date];
    NSCalendar *calendar;
    if(iOS8_constant_or_later){
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    }else{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }

    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDateComponents *currentComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:currentDate];
    NSString * takeDate = [NSString stringWithFormat:@"%2ld:%2ld",(long)currentComponents.hour,(long)currentComponents.minute];
    NSDateFormatter *dateFormatter = [NSDate format:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:takeDate];
    
    return date;
}
-(void)startBackgroundTimerWakeUp
{
    if(!wakeTimer)
    {
        NSTimeInterval count = [self wakeUpNoticeForWakeupWithWakeUpTime:@"23:50"];
        NSTimeInterval second = [self wakeUpNoticeForWakeupWithWakeUpTime:@"11:50"];
        
        if(count > second)
        {
            count = second;
        }
        NSDate * current = [NSDate dateWithTimeIntervalSinceNow:count];
        count = 3;
        current = [NSDate dateWithTimeIntervalSinceNow:count];
        
        wakeTimer = [[NSTimer alloc] initWithFireDate:current
                                                   interval:12*60*60
                                                     target:self
                                             selector:@selector(startWebRequest:)
                                                   userInfo:nil
                                                    repeats:YES];

        
        [[NSRunLoop currentRunLoop] addTimer:wakeTimer forMode:NSDefaultRunLoopMode];
    }
    
}
-(void)startWebRequest:(NSTimer *)timer
{
    ZWSystemTotalRequestModel * model = (ZWSystemTotalRequestModel *) _sysRequestModel;
    if(!model){
        model = [[ZWSystemTotalRequestModel alloc] init];
        [model addSignalResponder:self];
        _sysRequestModel = model;
    }
    [model sendRequest];
}

#pragma mark ZWSystemTotalRequestModel
handleSignal( ZWSystemTotalRequestModel, requestError )
{
    
}
handleSignal( ZWSystemTotalRequestModel, requestLoading )
{
    
}
handleSignal( ZWSystemTotalRequestModel, requestLoaded )
{
    
    ZWSystemTotalRequestModel * model = (ZWSystemTotalRequestModel *) _sysRequestModel;
    NSArray * arr = model.sysArr;
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    for (ZWSysSellModel * eve in arr)
    {
        [manager localSaveSystemSellModel:eve];
    }
}






@end
